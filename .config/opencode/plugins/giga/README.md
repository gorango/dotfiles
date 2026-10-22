# giga

The OpenCode integration for `giga-mode`. The skill tree lives at
`skills/giga/` in this config. This directory adds the OpenCode glue.

## Shape

```
skills/giga/            giga skills, including giga-mode, setup-giga, declutter, control-ui, control-cli, and verify-this
agents/giga.md           primary agent, matches a playbook and keeps ownership
agents/giga-agent.md     subagent, executes one scoped unit
agents/giga-reviewer.md  subagent, review and panel seats with read-only file access
commands/giga*.md        five explicit entry points
plugins/giga/index.ts    three script wrappers
```

Agents and commands load the skill by ID with the `skill` tool. Playbooks are
resolved from the giga-mode skill's base directory, so the prompts do not
hardcode the install path.

## Why no full plugin

About 90 percent of giga-mode is prompt content. OpenCode already has skills,
agents, and commands for that. The plugin only wraps scripts that would
otherwise need a path guess:

| Tool              | Script                   |
| ----------------- | ------------------------ |
| `giga_check_plan` | `scripts/check-plan.mjs` |
| `giga_orch`       | `scripts/orch/orch.ts`   |
| `giga_pr_status`  | `scripts/watch-pr/watch-pr` |

`giga_pr_status` takes an optional `owner` and `repo`, so it can target any
repository, not just the current project. It caps query retries at one, so a
bad repo, a missing `gh`, or an auth failure returns a blocker in under a
second instead of hanging.

`giga_orch` asks for permission under the `giga.orch` action before a mutating
command. `opencode.json` maps that action to `ask`. The assert passes the store
and the arguments as prompt metadata, so the prompt shows what will run.
Commands that only read or regenerate the derived `status.md` skip the check
either way.

## OpenCode conventions

- **Skills.** Load a hidden skill by ID with the `skill` tool, or mention
  `@skill-id`. Five giga skills are advertised: `setup-giga`, `declutter`,
  `control-cli`, `control-ui`, and `verify-this`. The other 53 set
  `disable-model-invocation` and are routed by `giga-mode` or invoked
  explicitly.
- **Todos.** `experimental.todo` is enabled in `opencode.json`, so playbook
  steps go into the `todowrite` tool instead of improvised prose.
- **Models.** References use `provider/model#variant`. The role map lives in
  `~/.config/opencode/giga-models.json`.
- **Permissions.** Global `permissions` carry the `giga.orch` rule. Agent
  files use the same ordered `{ action, resource, effect }` shape, with the
  last match winning.

## Use

```text
/giga fix the flaky retry test
/giga-babysit 412
/giga-ship 410,411,412
/giga-plan migrate the settings API
/giga-hillclimb boot time under 800ms
```

The primary agent is also selectable directly. It loads `giga-mode` before its
first action.

Long runs wake through a background `giga-agent` watcher with a terminal
verdict. `playbooks/autonomous-run.md` owns the cadence.

## Model routing

Agents inherit the session model by default. `giga-mode` reads
`~/.config/opencode/giga-models.json` for the per-role map and passes `model`
to the `subagent` tool. Code roles default to
`opencode-go/deepseek-v4.1-flash#high`; judgment roles default to
`opencode-go/minimax-m3.1-flash#xhigh`. Run `@setup-giga` to write the file.

`setup-giga` detects models from `opencode api get /api/model` and composes
references from each entry's `providerID`, `id`, and `variants`. IDs alone are
not unique, because the same model can exist under both `opencode` and
`opencode-go`.

## Paths

The plugin resolves the script root from its own location, so moving the tree
does not change it. `GIGA_SKILLS_ROOT` overrides that.

`opencode.json` registers the plugin as
`{env:HOME}/.config/opencode/plugins/giga`, so a different username needs no
edit. A non-default `XDG_CONFIG_HOME` still needs the registration and the
`~/.config/opencode` paths in generated plans changed. The multi-phase plan
playbook writes absolute paths into the plans it generates; edit those if the
config lives elsewhere.

## Tree notes

- `node_modules` is not committed. `scripts/bun.lock` is committed, and the
  first `orch` or `watch-pr` run installs dependencies with
  `bun install --frozen-lockfile`.
- The plugin typechecks with `bun run typecheck` from this directory. It uses
  the `tsconfig.json` here and `@types/bun`.
- `@tdd` resolves to the visible `skills/pocock/tdd`, which the bug-fix
  playbook uses.
- `giga-help` links and the absolute paths in
  `giga-mode/playbooks/multi-phase-plan.md` point at the installed
  `giga-mode/` tree.

## Known gaps

- `scripts/watch-pr` is GitHub-only and needs `gh`.
- `scripts/worktree-audit.sh` uses `git worktree list`, `du`, and `date`. It
  does not read session transcripts.
- `setup-giga` writes `~/.config/opencode/giga-models.json`. `giga-mode`
  reads it, but a skill that spawns a subagent must still pass the selected
  `model` explicitly.
