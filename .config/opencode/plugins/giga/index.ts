import { Plugin } from "@opencode/plugin"
import { spawn } from "node:child_process"
import { existsSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"

/**
 * giga-mode plugin.
 *
 * The prose lives in the skill tree, not here. This plugin only wraps
 * the three scripts an agent would otherwise have to path-guess:
 *
 *   giga_check_plan  scripts/check-plan.mjs
 *   giga_orch        scripts/orch/orch.ts
 *   giga_pr_status   scripts/watch-pr/watch-pr
 *
 * Keep this file thin. A playbook change belongs in the Markdown skill.
 */

const SKILLS =
  process.env.GIGA_SKILLS_ROOT ?? join(import.meta.dir, "../../skills")
const SCRIPTS = join(SKILLS, "giga/giga-mode/scripts")
const MAX_OUTPUT = 20_000

/**
 * OpenCode hosts plugins inside its own compiled binary, so process.execPath is
 * the opencode executable, not Bun. Resolve a real Bun from a known location,
 * then fall back to PATH.
 */
const BUN_CANDIDATES = [
  process.env.GIGA_BUN,
  join(homedir(), ".local/share/fnm/aliases/default/bin/bun"),
  "/usr/local/bin/bun",
  join(homedir(), ".bun/bin/bun"),
]

const RUNTIME =
  BUN_CANDIDATES.find((candidate) => candidate && existsSync(candidate)) ??
  "bun"

interface RunResult {
  code: number
  output: string
  truncated: boolean
}

function run(
  command: string,
  args: string[],
  signal: AbortSignal,
  cwd?: string,
): Promise<RunResult> {
  return new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd,
      signal,
      stdio: ["ignore", "pipe", "pipe"],
    })

    let output = ""
    let truncated = false

    const collect = (chunk: Buffer) => {
      if (output.length >= MAX_OUTPUT) {
        truncated = true
        return
      }
      output += chunk.toString()
    }

    child.stdout.on("data", collect)
    child.stderr.on("data", collect)
    child.on("error", (error) => {
      resolve({
        code: 127,
        output: `failed to start ${command}: ${error.message}`,
        truncated: false,
      })
    })
    child.on("close", (code) => {
      resolve({
        code: code ?? 1,
        output: output.trim(),
        truncated: truncated || output.length > MAX_OUTPUT,
      })
    })
  })
}

function report(result: RunResult): string {
  const body = result.output || (result.code === 0 ? "ok" : "no output")
  const clipped = result.truncated ? `${body.slice(0, MAX_OUTPUT)}\n[output truncated]` : body
  return result.code === 0 ? clipped : `${clipped}\n\n[exit ${result.code}]`
}

/**
 * Commands that only read or regenerate derived state (`status.md`), so they
 * need no write approval.
 */
function skipsWriteApproval(args: string[]): boolean {
  const [command, sub] = args
  switch (command) {
    case "status":
      return true
    case "unit":
      return sub === "get" || sub === "list" || sub === "counts"
    case "ledger":
      return sub === "check" || sub === "summary"
    case "gate":
      return sub === "list"
    case "frontier":
      return sub === "show"
    case "standing":
      return sub === "show"
    case "inbox":
      return sub === "count"
    default:
      return false
  }
}

export default Plugin.define({
  id: "giga",

  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.add({
        name: "giga_check_plan",
        description:
          "Validate a multi-phase giga plan file against the required skeleton and report every problem.",
        input: {
          type: "object",
          properties: {
            path: {
              type: "string",
              description: "Absolute path to the plan Markdown file.",
            },
          },
          required: ["path"],
          additionalProperties: false,
        },
        execute: async (input, context) => {
          const { path } = input as { path: string }
          const result = await run(
            RUNTIME,
            [join(SCRIPTS, "check-plan.mjs"), path],
            context.signal,
            ctx.location.directory,
          )
          return {
            content: report(result),
            metadata: { exitCode: result.code },
          }
        },
      })

      editor.add({
        name: "giga_orch",
        description:
          "Run an orchestrate store command against a giga-mode store directory. Read-only commands skip the write approval.",
        input: {
          type: "object",
          properties: {
            store: {
              type: "string",
              description: "Absolute path to the orchestrate store directory.",
            },
            args: {
              type: "array",
              items: { type: "string" },
              description:
                "Arguments after --store, such as [\"status\"] or [\"unit\", \"list\"].",
            },
          },
          required: ["store", "args"],
          additionalProperties: false,
        },
        execute: async (input, context) => {
          const { store, args } = input as { store: string; args: string[] }
          if (!skipsWriteApproval(args)) {
            await ctx.permission.assert({
              sessionID: context.sessionID,
              agent: context.agent,
              source: {
                type: "tool",
                messageID: context.messageID,
                id: context.id,
              },
              action: "giga.orch",
              resources: [store],
              save: [store],
              metadata: { store, args },
            })
          }
          const result = await run(
            RUNTIME,
            [join(SCRIPTS, "orch/orch.ts"), "--store", store, ...args],
            context.signal,
            ctx.location.directory,
          )
          return {
            content: report(result),
            metadata: { exitCode: result.code },
          }
        },
      })

      editor.add({
        name: "giga_pr_status",
        description:
          "One fast status pass on a GitHub pull request: CI, review threads, and merge state. Fails fast instead of retrying.",
        input: {
          type: "object",
          properties: {
            pr: { type: "number", description: "Pull request number." },
            owner: {
              type: "string",
              description: "Repository owner. Defaults to the current project.",
            },
            repo: {
              type: "string",
              description: "Repository name. Defaults to the current project.",
            },
            pretty: {
              type: "boolean",
              description: "Render a human table instead of JSON. Default true.",
            },
          },
          required: ["pr"],
          additionalProperties: false,
        },
        execute: async (input, context) => {
          const { pr, owner, repo, pretty = true } = input as {
            pr: number
            owner?: string
            repo?: string
            pretty?: boolean
          }
          const args = [
            join(SCRIPTS, "watch-pr/watch-pr"),
            "--pr",
            String(pr),
            "--status-only",
            "--max-query-errors",
            "1",
          ]
          if (owner) args.push("--owner", owner)
          if (repo) args.push("--repo", repo)
          if (pretty) args.push("--pretty")
          const result = await run(
            RUNTIME,
            args,
            context.signal,
            ctx.location.directory,
          )
          return {
            content: report(result),
            metadata: { exitCode: result.code },
          }
        },
      })
    })
  },
})
