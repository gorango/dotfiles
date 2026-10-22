# Oracle

A voice interface for OpenCode. You talk to your laptop from your phone and it
tells you what your sessions are doing, answers questions about them, and relays
instructions back.

Status: the agent and plugin work. The phone app does not exist yet.

---

## Shape

```
Pixel PWA ──HTTP/SSE──> OpenCode server
   │                        ├── oracle session  (agents/oracle.md)
   │                        │       └── oracle_* tools
   │                        └── oracle plugin   (plugins/oracle/index.ts)
   │                              ├── tool.transform    register tools
   │                              ├── session.hook      speech + capability limits
   │                              ├── tool.hook         gate other agents
   │                              ├── event.subscribe   session registry
   │                              └── storage           durable registry
   └── speaks whatever the oracle says
```

The phone knows about exactly one session, forever. Every other session is
reachable only through the plugin. That is the seam that keeps the client dumb.

---

## Agent versus plugin

They are different mechanisms and the distinction matters.

|             | Agent (`agents/oracle.md`) | Plugin (`plugins/oracle/index.ts`) |
| ----------- | -------------------------- | ---------------------------------- |
| Written in  | Markdown                   | TypeScript                         |
| Runs as     | system prompt              | code inside the server process     |
| Changes     | how the model behaves      | what the model can do              |
| Adds powers | no                         | yes                                |

The agent file alone cannot see other sessions. It supplies the persona and the
speech contract. The plugin supplies the capabilities. Both are required.

---

## What the plugin context actually provides

Verified against a running server, not inferred from documentation. Several
assumptions here were wrong at first and the design depends on the corrections.

| Capability                          | Available | Notes                                              |
| ----------------------------------- | --------- | -------------------------------------------------- |
| List sessions                       | **No**    | `ctx.session` has get/create/context/prompt/… only |
| Read a session's messages           | Yes       | `ctx.session.context`, needs a session id          |
| Send / steer / interrupt a session  | Yes       | `ctx.session.prompt`, `command`, `interrupt`       |
| Watch all sessions                  | Yes       | `ctx.event.subscribe`, across every location       |
| Persist state                       | Yes       | `ctx.storage`                                      |
| Scope plugin tools per agent        | **No**    | see below                                          |
| Strip builtin tools per agent       | Yes       | `session.hook("context")`, `event.tools`           |
| Inject system text per agent        | Yes       | `session.hook("context")`, `event.system`          |

Two findings that shaped the implementation:

**There is no session list.** The plugin cannot enumerate sessions. So it builds
its own registry from the public event stream and persists it in `ctx.storage`.
This is not a workaround: the same subscription is what the planned watch list
needs for proactive narration, so the overview and the notifications are one
component.

**A `context` hook cannot hide plugin-registered tools.** `event.tools` contains
builtin tools only (`edit`, `read`, `shell`, …); `oracle_*` never appears there.
Gating other agents therefore happens in `tool.hook("execute.before")` instead,
and it works by refusing execution rather than by hiding the definition.

---

## Tools

| Tool              | Effect | Purpose                                                 |
| ----------------- | ------ | ------------------------------------------------------- |
| `oracle_overview` | read   | List sessions with a short status each                  |
| `oracle_digest`   | read   | Recent requests, replies, and tools used in one session |
| `oracle_send`     | writes | Send a message to a session, queued or steering         |

Read-only is the default posture. `oracle_send` defaults to `queue`; `steer` must
be asked for explicitly, and the tool refuses to target another oracle session.

Enforcement, all verified live:

- The oracle holds **no mutating tools**. A context hook deletes `write`, `edit`,
  `bash` and `shell` from every oracle request, so the limit holds regardless of
  what the prompt says. Observed directly: 12 tools before, 9 after.
- Other agents cannot call `oracle_*`. A tool hook refuses execution, verified by
  being refused from a normal session.
- Sessions deleted mid-flight are pruned. The registry learns from events, and
  events never announce deletions, so every resolve re-verifies against the server
  before deciding a reference is ambiguous. Without that, a dead entry could make a
  unique reference look ambiguous and block a send.
- Cross-location calls pass the target's own location. Verified by sending from a
  session in one directory into a session in another; the message landed.

Speech-shaped output is produced by the tools, not by asking the model nicely.
Tool results are already digest-shaped, so the model mostly relays them.

---

## The speech contract

Everything the oracle says is spoken aloud. The rules live in
`agents/oracle.md` where they are editable, and are re-stated by a context hook
immediately before each oracle request so they cannot drift over a long session.

The durable mechanism is that **the tools never hand the model raw code, diffs,
or transcripts**. Digests are built to survive being spoken.

Convention for the client: **assistant text is spoken, tool calls are rendered
but silent.** The phone already receives both over the event stream, so
"speak the gist, show the detail" needs no extra protocol.

---

## Known rough edges

**Session titles are sentences.** OpenCode auto-generates titles like "Android
voice interface for live OpenCode sessions via Tailscale", and that is what a
voice would read out. Directory basenames (`dotfiles`, `twain-search-substrate`)
are far more speakable. The label policy is an open product decision.

**The registry is blind to the past.** It only knows sessions active since the
plugin first loaded, then persists across restarts. A session untouched for days
never appears.

**It only learns from events while subscribed.** Reloading a location is lazy —
the plugin instance is rebuilt when that location next runs something — so a
session created during the gap is missed, and the event stream has no replay. In
practice instances are long-lived and every session emits `session.created`, so
this only bites around reloads.

**Oracle sessions appear in their own overview.** They are tracked like any
other session and cannot currently be hidden, though the label makes them
recognisable.

---

## Phone client (not built)

Single-page app, served over Tailscale. Push-to-talk, not always-on listening:
Chrome on Android cannot hold the microphone open (`continuous` is broken), and
push-to-talk sidesteps that entirely.

- **Push-to-talk** — hold to speak, release to send. The primary control.
- **Oracle switcher** — bottom sheet: label, scope, last activity, unread dot.
- **Transcript** — readable detail; assistant text spoken, tool calls silent.
- **Mute** — you will want this in meetings.
- **Stop** — cancels speech and interrupts the oracle.
- **Status strip** — watched sessions with state and pending-approval badges.

Implementation notes: keep **one** event stream and filter client-side; the
stream is live-only, so populate the transcript with
`GET /api/session/{id}/message?limit=20` when switching.

The client can also cover the plugin's blind spot. It has `GET /api/session`,
which the plugin does not, so it can seed the registry through a plugin RPC
(`ctx.rpc.register`) — history the plugin cannot see on its own.

---

## Bounded oracle sessions

There should not be one unbounded oracle. An oracle is a **bounded conversation
with a scope and a speakable name**:

```ts
{ label: "twain search", id: "ses_...", scope: ["/home/g/m/twain-search-substrate"], lastUsed }
```

Scoping by project is the bounding mechanism — a project-scoped oracle is
naturally bounded and naturally named.

This is cheap because **an oracle's knowledge comes from tools, not from its own
memory**. Its window holds only the conversation. Throw one away and rebuild it
for nothing.

Bound them three ways: auto-`compact` at a token threshold, soft-archive when
idle, hard-delete on request. Cap the active list and let stale ones fall off.

Planned tools: `oracle_new`, `oracle_list`, `oracle_switch`, `oracle_rename`,
`oracle_archive`, `oracle_delete`.

Routing decision: **the client owns the active oracle.** No router session
deciding who should answer — that would reintroduce exactly the ambiguity that
makes voice commands get misrouted.

Note that a session created through the API needs an explicit model. Without one
it accepts a prompt and never runs.

---

## Deployment

Tailscale Serve fronts two origins, deliberately:

```
https://gx15.taila76ddf.ts.net       /  →  http://localhost:49374   OpenCode web UI
https://gx15.taila76ddf.ts.net:8443  /  →  http://127.0.0.1:8080   the voice client
                                     /api → http://127.0.0.1:49374/api
```

**The client must have its own origin, not a path.** The OpenCode web UI
registers a Workbox service worker at `/sw.js` with scope `/`, so in any browser
that has opened the UI, every navigation under that origin — `/voice` included —
is answered from its cache with the OpenCode app shell. Server-side routing is
irrelevant because the interception is in the browser. Verified: with the route
present the server returned the client correctly over `curl`, while a browser
with the worker installed showed the OpenCode UI.

Moving the OpenCode UI aside instead does not work either: its assets are
absolute (`/_assets/…`, `/icons/…`, `/site.webmanifest`), so any subpath breaks
them.

A separate port gives a separate origin, which gives a separate service worker
scope. HTTPS on a non-standard port is still a secure context, so the microphone
works.

The `/api` route repeats its prefix in the target because Tailscale strips the
matched path before proxying; the target carries it back, so the server sees
`/api/info` rather than `/info`. This keeps the client on the same origin as the
API, so no CORS work is needed — and there is no CORS configuration available to
set anyway.

The client serves itself; only the API port needs the OpenCode server.

### Two servers are running

| Process                     | Bind              | Sessions   | Notes                |
| --------------------------- | ----------------- | ---------- | -------------------- |
| systemd `opencode.service`  | `0.0.0.0:4096`    | none       | different auth token |
| managed background service  | `127.0.0.1:49374` | all        | what Tailscale fronts |

The systemd unit is a leftover from a different install and holds no sessions.
The plugin only works because it loads in the server that owns the sessions.

To fix:

1. The managed service's port is not pinned anywhere, but Tailscale Serve
   hardcodes 49374. If the service ever rebinds, the HTTPS URL dies silently.
2. `--hostname 0.0.0.0` exposes the API to whatever LAN the laptop joins. Bind
   localhost and let Tailscale Serve handle the network.

Something is also serving Chrome DevTools on `*:9222`, which is unauthenticated
remote browser control for anyone on the same network.

---

## Open questions

- The label policy: project directory, truncated title, or something else.
- Whether `oracle_digest` should summarise through `ctx.generate.text` instead of
  extracting deterministically. That needs a configured model reference.
- Whether `ctx.session.generate({ sessionID, prompt })` runs the target session's
  tool loop or answers purely from stored context. If it is read-only it is a
  better primitive than reading a transcript.
- The watch list: which events mean "this session needs you", and how the oracle
  is prompted when one fires.
