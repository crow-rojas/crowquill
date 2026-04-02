import { resolve } from "path"

import vue from "@vitejs/plugin-vue"
import { defineConfig } from "vitest/config"

const coverageScope = process.env.COVERAGE_SCOPE === "full" ? "full" : "gate"

const gatedCoverageInclude = [
  "app/frontend/components/dashboard/AdminDashboard.vue",
  "app/frontend/components/dashboard/TutorDashboard.vue",
  "app/frontend/components/dashboard/TutoradoDashboard.vue",
  "app/frontend/components/ExerciseEditor.vue",
  "app/frontend/components/FormInput.vue",
  "app/frontend/components/LatexRenderer.vue",
  "app/frontend/components/MarkdownLatex.vue",
  "app/frontend/components/NavMain.vue",
  "app/frontend/components/NavUser.vue",
  "app/frontend/components/UserMenuContent.vue",
  "app/frontend/composables/usePermissions.ts",
  "app/frontend/lib/utils.ts",
]

const fullCoverageInclude = ["app/frontend/**/*.{ts,vue}"]

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "app/frontend"),
    },
  },
  test: {
    globals: true,
    environment: "happy-dom",
    setupFiles: ["spec/frontend/setup.ts"],
    include: ["spec/frontend/**/*.{test,spec}.{ts,tsx}"],
    coverage: {
      provider: "v8",
      reportsDirectory:
        coverageScope === "full"
          ? "coverage/frontend-full"
          : "coverage/frontend",
      include:
        coverageScope === "full" ? fullCoverageInclude : gatedCoverageInclude,
      exclude: [
        "app/frontend/components/ui/**",
        "app/frontend/entrypoints/**",
        "app/frontend/routes/**",
        "app/frontend/ssr/**",
        "app/frontend/types/**",
        "app/frontend/**/*.d.ts",
      ],
      thresholds:
        coverageScope === "full"
          ? undefined
          : {
              lines: 80,
              functions: 80,
              branches: 80,
              statements: 80,
            },
    },
  },
})
