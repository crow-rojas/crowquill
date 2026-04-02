---
name: Install shadcn-vue components first
description: Always install shadcn-vue components via CLI before using them, never create custom alternatives
type: feedback
---

Always install shadcn-vue components via the CLI (`bunx shadcn-vue@latest add <component>`) before using them in code. Never create custom card-based or div-based alternatives when a proper shadcn-vue component exists (e.g., Table). If Node.js version is too old for the CLI, use nvm to switch to a compatible version (v22+) first.

**Why:** The user explicitly prefers using the official component library over custom implementations. shadcn-vue components follow consistent patterns and are maintained.

**How to apply:** Before writing any Vue page that needs a component not yet installed, check `app/frontend/components/ui/` for existence and install if missing. Use `source ~/.nvm/nvm.sh && nvm use 22` if needed for the CLI.
