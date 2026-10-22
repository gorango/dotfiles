---
name: setup-giga
description: Configure which models giga uses per role and at what reasoning budget. Writes ~/.config/opencode/giga-models.json and uses it to override the skill defaults. Use for @setup-giga, "configure giga models", "giga budget", or changing giga's model choices.
---

# Setup giga

Write `~/.config/opencode/giga-models.json`, the role map that `giga-mode` and the routed skills read.

## Steps

### 1. Detect available models

Enumerate the models and variants available in this session. Run `opencode api get /api/model` and read each entry's `providerID`, `id`, and `variants[].id`. The full reference is `<providerID>/<id>#<variant>`. IDs are not unique on their own: `deepseek-v4.1-flash` exists under both `opencode` and `opencode-go`. If that command is unavailable, use `/models` in the TUI or ask the user to paste the references they can select. Never write a model you have not confirmed is available. The aliases `inherit-parent` and `auto` are always valid even though they are not detected models.

### 2. Load current state

The default role map is the shape shown in step 5. If `~/.config/opencode/giga-models.json` already exists, read it and treat its `budget` and `roles` values as the current choices. Otherwise start from those defaults. A role not in step 5, such as `how critics`, is retired. Drop it.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer the `question` tool over free text. Offer these four options with these exact labels, and name the current budget when the file records one. With no file, say that `large` matches the skill defaults.

- `unlimited — max reasoning`
- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Build the working map from the skill defaults, and on a re-run keep any role you changed. The budget sets the target variant: `unlimited` → `max`, `large` → `xhigh`, `medium` → `high`, `small` → `medium`. Write each role's model as `provider/model#variant`. `opencode-go/minimax-m3.1-flash` has `low`, `medium`, `high`, `xhigh`, and `max`, so it takes the target directly. `opencode-go/deepseek-v4.1-flash` has only `low`, `high`, and `max`, so clamp down to the highest available at or below the target: `xhigh` and `high` → `high`, `medium` → `low`. If the result is not a detected variant of that model, mark the role as needing a choice. `inherit-parent` and `auto` do not change.

**(c) Show the roles and confirm.** Show every role with its model, marking any model not in the detected set as needing a choice. Also list each entry step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit-parent` and `auto` (both mean the role runs on the parent session model, so omit `model`) as the options. Prefer the `question` tool over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it, preferring a family different from the parent's. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every model written must be in the detected set. `inherit-parent` and `auto` always pass. If a chosen model is not available, stop and ask again.

### 5. Write the file

Write `~/.config/opencode/giga-models.json` with a `budget` string and a `roles` object. Overwrite the whole file so re-runs stay idempotent. Shape:

```json
{
  "budget": "large",
  "roles": {
    "feature, refactoring": "opencode-go/deepseek-v4.1-flash#high",
    "bug-fix": "opencode-go/deepseek-v4.1-flash#high",
    "perf-issue": "opencode-go/deepseek-v4.1-flash#high",
    "hillclimb": "opencode-go/deepseek-v4.1-flash#high",
    "judgment and prose": "opencode-go/minimax-m3.1-flash#xhigh",
    "hardest tasks": "opencode-go/minimax-m3.1-flash#max",
    "how explorer": "opencode-go/deepseek-v4.1-flash#high",
    "how explainer": "opencode-go/minimax-m3.1-flash#xhigh",
    "why investigators": "opencode-go/deepseek-v4.1-flash#high",
    "why synthesizer": "opencode-go/minimax-m3.1-flash#xhigh",
    "reflect tooling": "opencode-go/deepseek-v4.1-flash#high",
    "reflect judgment, divergent, synthesizer": "opencode-go/minimax-m3.1-flash#xhigh",
    "arena runners": [
      "opencode-go/minimax-m3.1-flash#xhigh",
      "opencode-go/deepseek-v4.1-flash#high"
    ],
    "arena cross-judge pool": [
      "opencode-go/minimax-m3.1-flash#xhigh",
      "opencode-go/deepseek-v4.1-flash#high"
    ],
    "swarm workers": "opencode-go/deepseek-v4.1-flash#high",
    "architect runners": [
      "opencode-go/minimax-m3.1-flash#xhigh",
      "opencode-go/deepseek-v4.1-flash#high"
    ],
    "interrogate reviewers": [
      "opencode-go/minimax-m3.1-flash#xhigh",
      "opencode-go/deepseek-v4.1-flash#high"
    ]
  }
}
```

### 6. Confirm

Tell the user the file was written. New sessions and subagent calls read it through `giga-mode`. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with the `create-verification-skill` skill." On yes, load `@create-verification-skill` (it resolves wherever giga is installed: workspace, user, or plugin). On no, move on without pushing.

### 8. Offer a formal verification skill (optional)

Check whether the project already has a formal verification skill (a project skill that runs a model checker, a proof, or another verifier against the code). If not, offer once: "want a formal verification skill, so agents can prove a key property of your code holds in every case in scope, not only the cases tests reach? I can generate one with the `create-formal-verification-skill` skill." On yes, load `@create-formal-verification-skill` (it resolves wherever giga is installed: workspace, user, or plugin). On no, move on without pushing.
