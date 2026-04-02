# Crowquill

Built with Rails 8 + Inertia.js + Vue 3. Rails owns routing, Vue owns rendering.

## Tech Stack

- **Backend:** Rails 8 + Ruby 4.0.2
- **Frontend:** Vue 3 + TypeScript via Inertia.js
- **UI:** shadcn-vue + Tailwind CSS 4
- **Build:** Vite (via `vite_rails` + Bun)
- **DB:** PostgreSQL 17
- **Auth:** Session-based (Authentication Zero)
- **i18n:** vue-i18n (es/en) + Rails i18n
- **Testing:** RSpec + Vitest (80% coverage thresholds)
- **Linting:** Rubocop + ESLint + Prettier (enforced via Lefthook git hooks)
- **CI:** GitHub Actions (lint, security scan, type check, tests)

## What's Included

- Full authentication flow (login, register, logout, password reset)
- Dashboard layout with sidebar navigation
- Settings pages (profile, password, appearance, language)
- Reusable form components (FormInput, FormSelect, FormTextarea, FormDatePicker, FormNumberInput, FormRadioGroup, FormCheckboxGroup, FormSwitch, SectionCard)
- i18n setup with cookie-persisted locale and language switcher
- Pre-configured git hooks (pre-commit: lint, pre-push: typecheck + tests)
- CI pipeline with lint, security scan, type check, and test jobs

## Prerequisites

- Ruby 4.0.1 (via `mise`, `rbenv`, or `asdf`)
- [Bun](https://bun.sh)
- [Docker](https://docs.docker.com/get-docker/) (for Postgres and Redis)

## Setup

```bash
# Start database and cache services
docker compose up -d

# Install dependencies
bundle install
bun install

# Create and migrate the database (first time only)
bin/rails db:create db:migrate

# Seed test data (optional)
bin/rails db:seed

# Start the dev server (Rails + Vite)
bin/dev
```

Open [http://localhost:3000](http://localhost:3000).

## Common Commands

```bash
bin/rails console          # Rails console
bin/rails db:migrate       # Run migrations
bin/rails db:seed          # Seed database
bin/rails routes           # List routes
bundle exec rspec          # Run backend tests
bunx vitest run            # Run frontend tests
bun run check              # TypeScript check
bun run lint               # ESLint
bun run format             # Prettier check
```

## Project Structure

```
app/
├── controllers/              # Render Inertia responses
├── models/                   # ActiveRecord models
├── frontend/                 # All Vue/TS code
│   ├── entrypoints/          # inertia.ts, application.css
│   ├── pages/                # Vue pages (match controller actions)
│   ├── components/           # Reusable + ui/ (shadcn-vue) + form/
│   ├── composables/          # use* hooks
│   ├── layouts/              # DashboardLayout, AuthLayout
│   ├── lib/                  # Shared helpers
│   ├── types/                # TypeScript types
│   └── i18n/locales/{es,en}/ # One JSON per domain
config/routes.rb              # All routing (Rails standard)
spec/                         # RSpec (backend) + Vitest (frontend)
```

## Customizing

1. Update database credentials in `config/database.yml` and `docker-compose.yml`
2. Update CI config in `.github/workflows/ci.yml` if you change DB credentials

See [AGENTS.md](AGENTS.md) for architecture details and conventions.
