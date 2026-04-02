# Rails + Inertia.js + Vue 3 Template

Starter template for modern Rails apps with a Vue 3 frontend via Inertia.js. Minimalist Apple-style UI.

## Stack

| Layer | Tech |
|-------|------|
| Backend | Rails 8, Ruby 4.0 |
| Frontend | Vue 3 + TypeScript (Inertia.js) |
| UI | shadcn-vue + Tailwind CSS 4 |
| Bridge | Inertia.js — no API mode, no vue-router |
| Build | Vite (`vite_rails` gem) + Bun |
| DB | PostgreSQL 17 (ActiveRecord) |
| Auth | Session-based (`has_secure_password` + Authentication Zero) |
| i18n | vue-i18n (`es` default, `en`) |

## Docs

| Topic | URL |
|-------|-----|
| Inertia Rails | https://inertia-rails.dev/ |
| Inertia Rails Cookbook | https://inertia-rails.dev/cookbook/integrating-shadcn-ui |
| Inertia.js | https://inertiajs.com/ |
| Vue 3 | https://vuejs.org/guide/introduction.html |
| shadcn-vue | https://www.shadcn-vue.com/docs |
| Tailwind CSS 4 | https://tailwindcss.com/docs |
| Vite Ruby | https://vite-ruby.netlify.app/ |
| Pinia | https://pinia.vuejs.org/ |

## How Inertia Works

Rails controllers render Vue components directly — no JSON API, no vue-router.

```ruby
render inertia: 'Items/Show', props: {
  item: item.as_json(include: :details)
}
```

```vue
<script setup lang="ts">
defineProps<{ item: Item }>()
</script>
```

- Rails owns routing, sessions, CSRF, auth.
- `<Link>` component for navigation. `useForm()` for submissions. Errors flow back automatically.
- Layouts assigned per-page or globally via `createInertiaApp` resolve function.
- Auth pages override: `defineOptions({ layout: AuthLayout })`.

## Project Structure

```
app/
├── controllers/              # Render Inertia responses (not ERB)
├── models/                   # ActiveRecord models
├── services/                 # Service objects for complex ops
├── policies/                 # Authorization
├── views/layouts/            # Root HTML shell (Vite + Inertia)
├── frontend/                 # All Vue/TS code
│   ├── entrypoints/          # inertia.ts, application.css
│   ├── pages/                # Vue pages (match controller actions)
│   ├── components/           # Reusable + ui/ (shadcn-vue) + form/
│   ├── composables/          # use* hooks
│   ├── layouts/              # DashboardLayout, AuthLayout
│   ├── stores/               # Pinia (global client state only)
│   ├── lib/                  # Shared helpers
│   ├── types/                # TypeScript types
│   └── i18n/locales/{es,en}/ # One JSON per domain
config/routes.rb              # All routing (Rails standard)
config/initializers/inertia_rails.rb
db/migrate/
spec/                         # RSpec + Vitest
```

## Design Patterns

### Rails
- **Inertia-first.** `render inertia:` not JSON. Only add API endpoints when genuinely needed.
- **Service objects** for complex operations.
- **Scoping:** Always through `current_user`.
- **String-backed enums.** Never integer-backed.
- **JSONB** for structured/flexible data.
- **RESTful resources.** Skinny controllers, fat models/services.

### Vue
- **SFCs only:** `<script setup lang="ts">`. No Options API.
- **shadcn-vue first.** Use primitives before custom. Customize via Tailwind classes.
- **Composables:** `use*` convention.
- **State:** Inertia props for page data. Pinia only for global client state (sidebar, locale). Composables for shared logic. Refs for local state.
- **Navigation:** `<Link>` or `router.visit()`. Never `<a href>` for internal links.
- **Forms:** `useForm()` — validation errors from Rails flow back automatically.

### i18n
- `vue-i18n`. Default: `es`. Cookie: `app_lang`.
- One file per domain: `common`, `auth`, `nav`, plus any app-specific domains.
- Templates: `$t('key')`. Script: `const { t } = useI18n()`.
- Reactive options must be `computed()`. Always add both locales.

### Form Components
- Reusable components in `app/frontend/components/form/`: FormInput, FormSelect, FormTextarea, FormCheckboxGroup, FormRadioGroup, FormDatePicker, FormNumberInput, FormSwitch, SectionCard.
- Every form component works for both creating (empty props) and editing (populated props). One component, one UX.
- Built on shadcn-vue primitives with consistent error display and i18n support.

## Testing

### Backend (RSpec)
- Model: RSpec + Shoulda Matchers (`spec/models/`)
- Request: RSpec + FactoryBot (`spec/requests/`)
- Service: RSpec (`spec/services/`)
- Inertia: `have_rendered_component`, `have_passed_prop`

### Frontend (Vitest)
- Unit: pure functions (`spec/frontend/unit/`)
- Component: Vue Test Utils (`spec/frontend/components/`)
- Locale-agnostic assertions. `vi.useFakeTimers()` for dates.

### Coverage
80% minimum (backend: simplecov, frontend: @vitest/coverage-v8).

## Git Hooks (Lefthook)
- `pre-commit`: Lint staged (Rubocop for .rb, ESLint for .ts/.vue, Prettier for formatting)
- `pre-push`: Type check + full test suite, blocks if tests fail or coverage < 80%

## Coding Principles

- Single deployable app. Frontend (`app/frontend/`) is part of Rails, not a separate package.
- Responsive + touch-friendly (44px min tap targets, `env(safe-area-inset-*)`).
- TypeScript strict on frontend. Rubocop defaults on backend.
- No SSR. Capacitor-ready for mobile wrapping.
