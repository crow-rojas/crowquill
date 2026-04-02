---
name: add-component
description: Add shadcn-vue components to the project. Use when installing UI components, adding shadcn components, or when a needed component isn't in the project yet.
---

## Adding shadcn-vue Components

When adding components to this project:

1. **Check if the component already exists** in `app/frontend/components/ui/`
2. **Install using the CLI**: `bunx shadcn-vue@latest add <component-name>`
3. **Verify installation** by checking the component was created in `app/frontend/components/ui/<component-name>/`

### Important Notes

- This project uses **shadcn-vue** (Vue port), not shadcn/ui (React)
- Style: `new-york`
- Icon library: `lucide` (via `lucide-vue-next`)
- Components land in `app/frontend/components/ui/`
- Composables land in `app/frontend/composables/`
- Utils are in `app/frontend/lib/utils.ts`
- Always use `bunx`, never `npx`

### Installing Multiple Components

```bash
bunx shadcn-vue@latest add button card dialog
```

### Available Component Categories

Use the shadcn-vue MCP server to browse and search available components. You can also check https://www.shadcn-vue.com/docs/components for the full list.

### After Installation

- Import from the component's index: `import { Button } from '@/components/ui/button'`
- Components use Tailwind CSS 4 for styling
- Check `components.json` for project configuration
