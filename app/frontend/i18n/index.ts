import { createI18n } from "vue-i18n"

import enAcademic from "@/i18n/locales/en/academic.json"
import enAi from "@/i18n/locales/en/ai.json"
import enAttendance from "@/i18n/locales/en/attendance.json"
import enAuth from "@/i18n/locales/en/auth.json"
import enCommon from "@/i18n/locales/en/common.json"
import enDashboard from "@/i18n/locales/en/dashboard.json"
import enEnrollment from "@/i18n/locales/en/enrollment.json"
import enExercises from "@/i18n/locales/en/exercises.json"
import enNav from "@/i18n/locales/en/nav.json"
import enOnboarding from "@/i18n/locales/en/onboarding.json"
import esAcademic from "@/i18n/locales/es/academic.json"
import esAi from "@/i18n/locales/es/ai.json"
import esAttendance from "@/i18n/locales/es/attendance.json"
import esAuth from "@/i18n/locales/es/auth.json"
import esCommon from "@/i18n/locales/es/common.json"
import esDashboard from "@/i18n/locales/es/dashboard.json"
import esEnrollment from "@/i18n/locales/es/enrollment.json"
import esExercises from "@/i18n/locales/es/exercises.json"
import esNav from "@/i18n/locales/es/nav.json"
import esOnboarding from "@/i18n/locales/es/onboarding.json"

function getStoredLocale(): "es" | "en" {
  if (typeof document === "undefined") return "es"
  const match = document.cookie.match(/app_lang=(es|en)/)
  return (match?.[1] as "es" | "en") ?? "es"
}

export function setLocale(locale: "es" | "en") {
  i18n.global.locale.value = locale
  document.cookie = `app_lang=${locale};path=/;max-age=${60 * 60 * 24 * 365};SameSite=Lax`
  document.documentElement.lang = locale
}

const i18n = createI18n({
  legacy: false,
  locale: getStoredLocale(),
  fallbackLocale: "en",
  messages: {
    es: {
      ...esCommon,
      ...esAuth,
      ...esNav,
      ...esOnboarding,
      ...esAcademic,
      ...esEnrollment,
      ...esExercises,
      ...esAttendance,
      ...esDashboard,
      ...esAi,
    },
    en: {
      ...enCommon,
      ...enAuth,
      ...enNav,
      ...enOnboarding,
      ...enAcademic,
      ...enEnrollment,
      ...enExercises,
      ...enAttendance,
      ...enDashboard,
      ...enAi,
    },
  },
})

export default i18n
