---
name: variable-font-loading-budget
description: "Optimize variable-font delivery without sacrificing language coverage or layout stability."
---

# Variable Font Loading Budget

## Decisions And Evidence

1. Measure actual used glyph ranges/axes, fallback metrics, font transfer and text visibility on the target routes.
2. Compare cold/warm navigation, font failure and localized text; preload only demonstrated critical font resources.

## Boundary

Check redistribution/subsetting rights; fewer files do not necessarily mean less transfer or decode cost.

## Source

[Current primary reference](https://web.dev/articles/font-best-practices). Check the installed version and current contract before execution.
