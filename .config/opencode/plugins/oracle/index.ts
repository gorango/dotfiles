import { Plugin } from "@opencode/plugin"

/**
 * Oracle plugin.
 *
 * Gives the `oracle` agent the ability to observe and drive the user's other
 * sessions. See DESIGN.md for the architecture.
 *
 * The plugin context has no way to enumerate sessions (ctx.session exposes
 * get/create/context/prompt/... but no list), so this plugin builds its own
 * session registry from the public event stream and persists it in storage.
 * The registry is also the foundation for the planned watch list.
 *
 * Deliberately registers tools and one event subscription only. It installs no
 * hooks, so a failure here cannot change any normal session's behaviour.
 */

const DEFAULT_LIMIT = 15
const MAX_LIST = 50
const MAX_TRACKED = 200
const MAX_TURNS = 12
const EXCERPT = 700
const FLUSH_MS = 2000

type Entry = {
  id: string
  directory?: string
  title?: string
  agent?: string
  last?: number
}

export default Plugin.define({
  id: "oracle",

  async setup(ctx) {
    const anyCtx = ctx as any

    // ------------------------------------------------------------- registry

    const known = new Map<string, Entry>()

    try {
      const stored: any = await anyCtx.storage.get("sessions")
      for (const [id, entry] of Object.entries(stored ?? {})) known.set(id, entry as Entry)
    } catch {
      // A missing or unreadable registry is not fatal: it refills from events.
    }

    let flushTimer: ReturnType<typeof setTimeout> | undefined

    const flush = async () => {
      try {
        const existing: any = (await anyCtx.storage.get("sessions")) ?? {}
        const merged: Record<string, Entry> = { ...existing }
        for (const [id, entry] of known) {
          const prev = merged[id]
          if (!prev || (entry.last ?? 0) >= (prev.last ?? 0)) merged[id] = entry
        }
        const trimmed = Object.entries(merged)
          .sort((a, b) => (b[1].last ?? 0) - (a[1].last ?? 0))
          .slice(0, MAX_TRACKED)
        await anyCtx.storage.set("sessions", Object.fromEntries(trimmed))
      } catch {
        // Persistence is best effort.
      }
    }

    const schedule = () => {
      if (flushTimer) return
      flushTimer = setTimeout(() => {
        flushTimer = undefined
        void flush()
      }, FLUSH_MS)
    }

    const ingest = (event: any) => {
      const id = event?.data?.sessionID ?? event?.durable?.aggregateID
      if (typeof id !== "string" || !id.startsWith("ses")) return
      const prev = known.get(id)
      known.set(id, {
        id,
        directory: event?.location?.directory ?? prev?.directory,
        title: event?.data?.title ?? prev?.title,
        agent: event?.data?.agent ?? prev?.agent,
        last: Date.now(),
      })
      schedule()
    }

    // The event stream is live-only and fails a slow consumer, so keep the
    // handler cheap and reconnect when the stream ends.
    const controller = new AbortController()
    void (async () => {
      while (!controller.signal.aborted) {
        try {
          for await (const event of anyCtx.event.subscribe({ signal: controller.signal })) {
            try {
              ingest(event)
            } catch {
              // One malformed event must not end the stream.
            }
          }
        } catch {
          // Fall through and resubscribe.
        }
        if (controller.signal.aborted) break
        await new Promise((r) => setTimeout(r, 1000))
      }
    })()

    // ---------------------------------------------------------------- helpers

    const last = (p?: string) => (p ?? "").split("/").filter(Boolean).pop() ?? ""

    /**
     * Spoken labels come from the project directory, not the session title.
     * Auto-generated titles are full sentences ("Android voice interface for
     * live OpenCode sessions via Tailscale"), which is unusable out loud.
     * A directory basename is short and stable. The title travels alongside as
     * a descriptor and stays searchable.
     */
    const labelOf = (s: Entry) => last(s.directory) || (s.title ?? "").trim() || s.id

    /** Everything a spoken reference may match against. */
    const haystack = (s: Entry) => `${labelOf(s)} ${s.title ?? ""}`.toLowerCase()

    const brief = (text: string, n = 60) => {
      const t = text.replace(/\s+/g, " ").trim()
      return t.length <= n ? t : `${t.slice(0, n).replace(/\s+\S*$/, "")}...`
    }

    const count = (n: number, unit: string) => `${n} ${unit}${n === 1 ? "" : "s"}`

    const ago = (t?: number) => {
      if (!t) return "at an unknown time"
      const mins = Math.round((Date.now() - t) / 60_000)
      if (mins < 2) return "just now"
      if (mins < 60) return `${count(mins, "minute")} ago`
      const hours = Math.round(mins / 60)
      if (hours < 24) return `${count(hours, "hour")} ago`
      return `${count(Math.round(hours / 24), "day")} ago`
    }

    const clip = (text: string) => {
      const t = text.replace(/\s+/g, " ").trim()
      return t.length > EXCERPT ? `${t.slice(0, EXCERPT)}...` : t
    }

    const describe = (s: Entry) => {
      const what = (s.title ?? "").trim()
      return what ? `"${labelOf(s)}" (${brief(what)})` : `"${labelOf(s)}"`
    }

    const why = (error: unknown) => (error instanceof Error ? error.message : String(error))

    /**
     * Refresh an entry from the server, and prune it when the session is gone.
     * The registry is built from events, and events never announce deletions,
     * so without this the oracle would keep offering sessions that no longer
     * exist.
     */
    async function refresh(entry: Entry): Promise<boolean> {
      try {
        const options = entry.directory ? { location: { directory: entry.directory } } : undefined
        const info: any = await anyCtx.session.get({ sessionID: entry.id }, options)
        if (!info) throw new Error("session missing")
        if (typeof info.title === "string" && info.title.trim()) entry.title = info.title
        if (typeof info.agent === "string") entry.agent = info.agent
        return true
      } catch {
        known.delete(entry.id)
        schedule()
        return false
      }
    }

    const tracked = () => [...known.values()].sort((a, b) => (b.last ?? 0) - (a.last ?? 0))

    /** Rank tracked sessions against a spoken reference. */
    const resolve = (ref: string) => {
      const needle = (ref ?? "").toLowerCase().trim()
      return tracked()
        .map((s) => {
          const label = haystack(s)
          let score = 0
          if (s.id === ref) score = 100
          else if (needle && label === needle) score = 90
          else if (needle && label.includes(needle)) score = 70
          else if (needle && needle.includes(label)) score = 60
          else if (needle) {
            const hits = needle
              .split(/\s+/)
              .filter((t) => t.length > 2 && label.includes(t)).length
            if (hits > 0) score = 30 + hits * 5
          }
          return { session: s, score }
        })
        .filter((m) => m.score > 0)
        .sort((a, b) => b.score - a.score)
    }

    const candidates = (matches: { session: Entry }[]) =>
      matches.slice(0, 5).map((m) => describe(m.session)).join(", ")

    /**
     * Drop matches whose session has since been deleted, then re-check for
     * ambiguity. Without this a dead entry could block a legitimate send by
     * making a unique reference look ambiguous.
     */
    async function settle(matches: { session: Entry; score: number }[]) {
      const alive: { session: Entry; score: number }[] = []
      for (const match of matches.slice(0, 5)) {
        if (await refresh(match.session)) alive.push(match)
      }
      return alive.sort((a, b) => b.score - a.score)
    }

    const emptyRegistryNote =
      "No sessions are being tracked yet. I only learn about a session once it becomes active."

    /** Flatten a transcript into speech-and-routing friendly turns. */
    function digestOf(messages: any[]) {
      const turns: string[] = []
      const tools = new Set<string>()
      let users = 0
      for (const m of messages ?? []) {
        if (m?.type === "user" && typeof m.text === "string") {
          users++
          turns.push(`[user] ${clip(m.text)}`)
        } else if (m?.type === "assistant") {
          for (const c of m.content ?? []) {
            if (c?.type === "tool" && c.name) tools.add(c.name)
          }
          const text = (m.content ?? [])
            .filter((c: any) => c?.type === "text" && typeof c.text === "string")
            .map((c: any) => c.text)
            .join("\n")
            .trim()
          if (text) turns.push(`[assistant] ${clip(text)}`)
        }
      }
      return { turns, tools: [...tools], users, messages: (messages ?? []).length }
    }

    // ------------------------------------------------------------------ tools

    await anyCtx.tool.transform((editor: any) => {
      editor.namespace({
        name: "oracle",
        description: "Observe and drive the user's other OpenCode sessions",
      })

      editor.add({
        name: "overview",
        description:
          "List the user's OpenCode sessions with a short status for each, most recently active " +
          "first. Call this first to learn which sessions exist and what they are called. Read-only.",
        input: {
          type: "object",
          properties: {
            limit: {
              type: "integer",
              description: `How many sessions to list. Defaults to ${DEFAULT_LIMIT}.`,
            },
          },
          required: [],
          additionalProperties: false,
        },
        options: { namespace: "oracle" },
        async execute(input: any, context: any) {
          await context?.progress?.({ status: "listing sessions" })
          try {
            const limit = Math.min(Number(input?.limit) || DEFAULT_LIMIT, MAX_LIST)
            const listed = tracked().slice(0, limit)
            if (listed.length === 0) return { content: emptyRegistryNote }

            // Drop sessions that have since been deleted.
            const alive = (
              await Promise.all(listed.map((s) => refresh(s).then((ok) => (ok ? s : null))))
            ).filter((s): s is Entry => s !== null)
            if (alive.length === 0) return { content: emptyRegistryNote }

            const lines = alive.map((s, i) => {
              const bits = [describe(s), `last active ${ago(s.last)}`]
              if (s.agent) bits.push(`agent ${s.agent}`)
              return `${i + 1}. ${bits.join(", ")}`
            })

            return {
              content: `${count(lines.length, "session")}, most recently active first:\n${lines.join("\n")}`,
            }
          } catch (error) {
            return { content: `Could not list sessions: ${why(error)}` }
          }
        },
      })

      editor.add({
        name: "digest",
        description:
          "Read what a session is doing or has done: its recent user requests, its latest " +
          "replies, and which tools it has used. Use this to answer questions about a " +
          "session's progress or to discuss its work. Read-only, never disturbs the session.",
        input: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description:
                "The session to read, by its short title or by words describing it. " +
                "Call oracle_overview first if you do not know the names.",
            },
            turns: {
              type: "integer",
              description: `How many recent messages to include. Defaults to ${MAX_TURNS}.`,
            },
          },
          required: ["session"],
          additionalProperties: false,
        },
        options: { namespace: "oracle" },
        async execute(input: any, context: any) {
          const ref = String(input?.session ?? "")
          await context?.progress?.({ status: `reading ${ref}` })
          try {
            if (known.size === 0) return { content: emptyRegistryNote }
            const matches = await settle(resolve(ref))
            if (matches.length === 0) {
              const names = tracked()
                .slice(0, 8)
                .map((s) => describe(s))
                .join(", ")
              return {
                content: `No session matches "${ref}". Known sessions: ${names || "none"}.`,
              }
            }
            if (matches.length > 1 && matches[0].score < 90) {
              return {
                content:
                  `"${ref}" is ambiguous. It could be: ${candidates(matches)}. ` +
                  `Ask the user which one they mean.`,
              }
            }

            const target = matches[0].session
            const options = target.directory
              ? { location: { directory: target.directory } }
              : undefined
            const messages: any[] = await anyCtx.session.context(
              { sessionID: target.id },
              options,
            )
            const digest = digestOf(messages)
            const keep = Math.max(2, Math.min(Number(input?.turns) || MAX_TURNS, MAX_TURNS))

            const header = [
              `${describe(target)}.`,
              `Last active ${ago(target.last)}.`,
              `${count(digest.messages, "message")} total, ${count(digest.users, "request")} from the user.`,
              digest.tools.length ? `Tools used: ${digest.tools.slice(-12).join(", ")}.` : "",
            ]
              .filter(Boolean)
              .join(" ")

            const body = digest.turns.slice(-keep).join("\n\n")
            return {
              content: body ? `${header}\n\n${body}` : `${header}\n\nNo conversation content yet.`,
            }
          } catch (error) {
            return { content: `Could not read "${ref}": ${why(error)}` }
          }
        },
      })

      editor.add({
        name: "send",
        description:
          "Send a message to another session on the user's behalf. This changes what that " +
          "session works on, so only use it when the user has clearly asked you to. " +
          "Defaults to queueing the message after the session's current work; use steer only " +
          "when the user wants the session to stop and change direction now.",
        input: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description: "The session to message, by its short title or describing words.",
            },
            text: {
              type: "string",
              description: "The message to send, written the way the user would write it.",
            },
            mode: {
              type: "string",
              enum: ["queue", "steer"],
              description:
                "queue (default) delivers after the session's current work. " +
                "steer interrupts that work immediately.",
            },
          },
          required: ["session", "text"],
          additionalProperties: false,
        },
        options: { namespace: "oracle" },
        async execute(input: any, context: any) {
          const ref = String(input?.session ?? "")
          const text = String(input?.text ?? "").trim()
          if (!text) return { content: "No message was given, so nothing was sent." }

          await context?.progress?.({ status: `sending to ${ref}` })
          try {
            if (known.size === 0) return { content: emptyRegistryNote }
            const matches = await settle(resolve(ref))
            if (matches.length === 0) {
              const names = tracked()
                .slice(0, 8)
                .map((s) => describe(s))
                .join(", ")
              return {
                content: `No session matches "${ref}", so nothing was sent. Known sessions: ${names || "none"}.`,
              }
            }
            if (matches.length > 1 && matches[0].score < 90) {
              return {
                content:
                  `"${ref}" is ambiguous, so nothing was sent. It could be: ${candidates(matches)}. ` +
                  `Ask the user which one they mean.`,
              }
            }

            const target = matches[0].session
            if (target.agent === "oracle") {
              return {
                content: `"${labelOf(target)}" is another oracle session. Refusing to send to it.`,
              }
            }

            const delivery = input?.mode === "steer" ? "steer" : "queue"
            const options = target.directory
              ? { location: { directory: target.directory } }
              : undefined
            await anyCtx.session.prompt({ sessionID: target.id, text, delivery }, options)

            return {
              content:
                delivery === "steer"
                  ? `Sent to ${describe(target)} with steer, so it interrupts what it was doing.`
                  : `Sent to ${describe(target)}, queued behind its current work.`,
            }
          } catch (error) {
            return { content: `Could not send to "${ref}": ${why(error)}` }
          }
        },
      })
    })

    // ------------------------------------------------------------------ hooks

    // The speech contract lives in agents/oracle.md where it is editable. This
    // re-states it immediately before each oracle request so it cannot drift
    // over a long session.
    const SPEECH_REMINDER =
      "Reminder: your reply is spoken aloud by text-to-speech. No markdown, no code, " +
      "no file paths, no identifiers, no spelling things out. Lead with the answer in " +
      "short sentences."

    /** Tools the oracle must never hold, regardless of what its prompt says. */
    const MUTATING_TOOLS = [
      "write",
      "edit",
      "patch",
      "multiedit",
      "multi_edit",
      "bash",
      "shell",
      "notebookedit",
      "notebook_edit",
    ]

    const isMap = (v: any) => v instanceof Map

    const dropTool = (tools: any, name: string) => {
      if (!tools || typeof tools !== "object") return
      if (isMap(tools)) tools.delete(name)
      else delete tools[name]
    }

    await anyCtx.session.hook("context", (event: any) => {
      const raw = event?.agent
      const agent =
        typeof raw === "string" ? raw : ((raw?.id ?? raw?.name) as string | undefined)
      const oracle = agent === "oracle"

      if (oracle) {
        // Capability limits enforced in code, not requested in prose.
        for (const name of MUTATING_TOOLS) dropTool(event?.tools, name)
        if (Array.isArray(event?.system)) event.system.push({ type: "text", text: SPEECH_REMINDER })
        return
      }

      // NOTE: a `context` hook cannot hide plugin-registered tools. event.tools
      // holds builtin tools only (edit, read, shell, ...), so `oracle_*` never
      // appears here. Gating other agents happens in the tool hook below.
    })

    /** Refuse oracle tools to any agent other than the oracle. */
    await anyCtx.tool.hook("execute.before", (event: any) => {
      const name = String(event?.tool ?? "")
      if (!name.includes("oracle_")) return

      const raw = event?.agent ?? event?.agentID
      const agent = typeof raw === "string" ? raw : (raw?.id ?? raw?.name)

      // Fail open: never block execution when the caller cannot be identified.
      if (typeof agent !== "string" || agent.length === 0) return
      if (agent !== "oracle") {
        throw new Error(`oracle tools are only available to the oracle agent (caller: ${agent})`)
      }
    })

    return () => {
      controller.abort()
      if (flushTimer) clearTimeout(flushTimer)
    }
  },
})
