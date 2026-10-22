---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Locate the active transcript

Before fanning out, use the OpenCode session API in [`../giga-mode/references/session-api.md`](../giga-mode/references/session-api.md) to find the current session and read its messages. If the transcript is unavailable, pass a tight summary of the conversation instead. Do not read another project's session.

## 2. Spawn three reviewers in parallel

One message, three `subagent` calls, `agent: "giga-reviewer"`. That agent allows MCP access and denies edits, which is what the reviewers need to look up the tickets, chat threads, and observability traces the transcript references.

Each reviewer and the synthesizer name a `roles[...]` entry in `~/.config/opencode/giga-models.json` and a default. Set `model` to that entry's value, or to the default if the file or the entry is missing. Leave `model` unset when the value is `auto` or `inherit-parent`. If the runtime rejects a model, use the default and say so. If it rejects the default, use the closest valid model from its error message. Pick each subagent's effort variant for the job, per the Subagents section of the **giga-mode** skill.

| Lens | Role entry | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `opencode-go/minimax-m3.1-flash#xhigh` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `opencode-go/deepseek-v4.1-flash#high` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `opencode-go/minimax-m3.1-flash#xhigh` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript digest where marked. Reviewers return findings in the subagent result.

## 3. Synthesize

One `subagent` call, `agent: "giga-reviewer"`, `model` from `roles["reflect judgment, divergent, synthesizer"]` (default `opencode-go/minimax-m3.1-flash#xhigh`). It spot-verifies citations through MCP. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): write it directly following the OpenCode skill format (`https://opencode.ai/v2/docs/skills/`), then run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): edit the skill's `description` directly and test its trigger.
- `new skill: <kebab-name>`: create `.opencode/skills/<kebab-name>/SKILL.md` following the OpenCode skill format. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
