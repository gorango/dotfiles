---
description: Improve one metric against a target with the giga hillclimb playbook
agent: giga
---

Load the `giga-mode` skill (`id: giga-mode`), then open `playbooks/hillclimb.md` from that skill's base directory. Freeze a sensitive measurement harness. One hypothesis per iteration. Keep only changes that move the metric past noise and keep the regression gate green.

Metric and target: $ARGUMENTS
