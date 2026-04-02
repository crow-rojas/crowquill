import { resolve } from "path"

import vue from "@vitejs/plugin-vue"
import { defineConfig } from "vitest/config"

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "app/frontend"),
    },
  },
  test: {
    globals: true,
    environment: "jsdom",
    include: ["spec/frontend/**/*.{test,spec}.{ts,tsx}"],
    coverage: {
      provider: "v8",
      reportsDirectory: "coverage/frontend",
      include: ["app/frontend/**/*.{ts,vue}"],
      exclude: [
        "app/frontend/components/ui/**",
        "app/frontend/entrypoints/**",
        "app/frontend/**/*.d.ts",
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
})
