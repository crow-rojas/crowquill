import { createI18n } from "vue-i18n"

import enAcademic from "@/i18n/locales/en/academic.json"
import enAi from "@/i18n/locales/en/ai.json"
import enAttendance from "@/i18n/locales/en/attendance.json"
import enAuth from "@/i18n/locales/en/auth.json"
import enCommon from "@/i18n/locales/en/common.json"
import enDashboard from "@/i18n/locales/en/dashboard.json"
import enEnrollment from "@/i18n/locales/en/enrollment.json"
import enExercises from "@/i18n/locales/en/exercises.json"
import enLanding from "@/i18n/locales/en/landing.json"
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
import esLanding from "@/i18n/locales/es/landing.json"
import esNav from "@/i18n/locales/es/nav.json"
import esOnboarding from "@/i18n/locales/es/onboarding.json"

function persistLocaleCookie(locale: "es" | "en") {
  if (typeof document === "undefined") return

  document.cookie = `app_lang=${locale};path=/;max-age=${60 * 60 * 24 * 365};SameSite=Lax`
}

function getStoredLocale(): "es" | "en" {
  if (typeof document === "undefined") return "es"
  const match = document.cookie.match(/app_lang=(es|en)/)
  if (match?.[1]) {
    return match[1] as "es" | "en"
  }

  // Keep backend flash locale aligned with frontend default locale.
  persistLocaleCookie("es")
  return "es"
}

export function setLocale(locale: "es" | "en") {
  i18n.global.locale.value = locale
  persistLocaleCookie(locale)
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
      ...esLanding,
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
      ...enLanding,
    },
  },
})

export default i18n
