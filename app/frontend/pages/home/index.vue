<script setup lang="ts">
import { Head, Link } from "@inertiajs/vue3"
import { BookOpen, GraduationCap, MessageCircle, Users } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Button } from "@/components/ui/button"
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { dashboardPath, signInPath, signUpPath } from "@/routes"

const { t } = useI18n()
</script>

<template>
  <Head :title="t('landing.title')" />

  <div
    class="min-h-screen bg-gradient-to-b from-slate-50 to-white dark:from-slate-950 dark:to-slate-900"
  >
    <!-- Nav -->
    <header class="border-b border-slate-200 dark:border-slate-800">
      <div
        class="mx-auto flex max-w-6xl items-center justify-between px-4 py-4 sm:px-6"
      >
        <div class="flex items-center gap-2">
          <GraduationCap class="text-primary h-7 w-7" />
          <span class="text-xl font-bold tracking-tight">Crowquill</span>
        </div>
        <nav class="flex items-center gap-3">
          <Button
            v-if="$page.props.auth?.user"
            as-child
            variant="default"
            size="sm"
          >
            <Link :href="dashboardPath()">
              {{ t("landing.go_to_dashboard") }}
            </Link>
          </Button>
          <template v-else>
            <Button as-child variant="ghost" size="sm">
              <Link :href="signInPath()">
                {{ t("landing.sign_in") }}
              </Link>
            </Button>
            <Button as-child variant="default" size="sm">
              <Link :href="signUpPath()">
                {{ t("landing.sign_up") }}
              </Link>
            </Button>
          </template>
        </nav>
      </div>
    </header>

    <!-- Hero -->
    <section class="mx-auto max-w-6xl px-4 py-16 text-center sm:px-6 sm:py-24">
      <h1 class="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
        {{ t("landing.hero_title") }}
      </h1>
      <p
        class="text-muted-foreground mx-auto mt-6 max-w-2xl text-lg sm:text-xl"
      >
        {{ t("landing.hero_subtitle") }}
      </p>
      <div
        class="mt-10 flex flex-col items-center gap-4 sm:flex-row sm:justify-center"
      >
        <Button as-child size="lg" class="min-h-[48px] px-8 text-base">
          <Link :href="signUpPath()">
            {{ t("landing.get_started") }}
          </Link>
        </Button>
        <Button
          as-child
          variant="outline"
          size="lg"
          class="min-h-[48px] px-8 text-base"
        >
          <Link :href="signInPath()">
            {{ t("landing.sign_in") }}
          </Link>
        </Button>
      </div>
    </section>

    <!-- Features -->
    <section class="mx-auto max-w-6xl px-4 pb-16 sm:px-6 sm:pb-24">
      <h2 class="mb-12 text-center text-2xl font-bold sm:text-3xl">
        {{ t("landing.features_title") }}
      </h2>
      <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader>
            <Users class="text-primary mb-2 h-8 w-8" />
            <CardTitle class="text-lg">
              {{ t("landing.feature_sections") }}
            </CardTitle>
            <CardDescription>
              {{ t("landing.feature_sections_desc") }}
            </CardDescription>
          </CardHeader>
        </Card>

        <Card>
          <CardHeader>
            <BookOpen class="text-primary mb-2 h-8 w-8" />
            <CardTitle class="text-lg">
              {{ t("landing.feature_exercises") }}
            </CardTitle>
            <CardDescription>
              {{ t("landing.feature_exercises_desc") }}
            </CardDescription>
          </CardHeader>
        </Card>

        <Card>
          <CardHeader>
            <GraduationCap class="text-primary mb-2 h-8 w-8" />
            <CardTitle class="text-lg">
              {{ t("landing.feature_attendance") }}
            </CardTitle>
            <CardDescription>
              {{ t("landing.feature_attendance_desc") }}
            </CardDescription>
          </CardHeader>
        </Card>

        <Card>
          <CardHeader>
            <MessageCircle class="text-primary mb-2 h-8 w-8" />
            <CardTitle class="text-lg">
              {{ t("landing.feature_ai") }}
            </CardTitle>
            <CardDescription>
              {{ t("landing.feature_ai_desc") }}
            </CardDescription>
          </CardHeader>
        </Card>
      </div>
    </section>

    <!-- Footer -->
    <footer class="border-t border-slate-200 dark:border-slate-800">
      <div class="mx-auto max-w-6xl px-4 py-8 text-center sm:px-6">
        <p class="text-muted-foreground text-sm">
          {{ t("landing.footer") }}
        </p>
      </div>
    </footer>
  </div>
</template>
