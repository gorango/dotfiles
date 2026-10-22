# OpenCode session API

Use the OpenCode session API for transcripts. Do not call another plugin's session tools.

Every read writes to a temp file first. A direct `opencode api ... | jq` pipe is truncated by the harness on large responses, and `jq` reports `Unfinished string at EOF`.

## List sessions

```sh
f=$(mktemp)
opencode api get /api/session > "$f"
jq -r '.data[] | [.id, .title, .location.directory, .time.updated, .agent] | @tsv' "$f"
rm "$f"
```

The fields are `id`, `title`, `location.directory`, `time.updated`, and `agent`. There is no `outcome` field. Use `location.directory` to match a project or worktree. Use `agent` to tell a subagent session from a primary one.

## Current running session

```sh
f=$(mktemp)
opencode api get /api/session/active > "$f"
jq -r '.data | keys[]' "$f"
rm "$f"
```

If more than one is running, pick the one whose title or `location.directory` matches this work.

## Read a session

For a full transcript, read the context:

```sh
f=$(mktemp)
opencode api get "/api/session/$id/context" > "$f"
jq -r '.data[] |
  if .type == "user" then "USER: \(.text)"
  elif .type == "assistant" then
    (.content[]? |
      if .type == "text" then "ASSISTANT: \(.text)"
      elif .type == "tool" then "TOOL \(.name): \(.state.input // {} | tostring | .[0:300])"
      else empty end)
  else empty end' "$f"
rm "$f"
```

The context is large. Write it to a file before filtering.

For the raw paginated messages:

```sh
f=$(mktemp)
opencode api get "/api/session/$id/message" > "$f"
jq -r '.data[] |
  if .type == "user" then "USER: \(.text)"
  elif .type == "assistant" then
    (.content[]? |
      if .type == "text" then "ASSISTANT: \(.text)"
      elif .type == "tool" then "TOOL \(.name): \(.state.input // {} | tostring | .[0:300])"
      else empty end)
  else empty end' "$f"
rm "$f"
```

`/api/session/$id/message` is paginated. If `.cursor.next` is non-null, request the next page with that cursor and append. For a full export, use `/api/experimental/session/$id/export`, still file-first.

## Worktree cleanup

Match `.location.directory` from `/api/session` against `git worktree list`. Do not read message bodies just to find which worktree a session used.
