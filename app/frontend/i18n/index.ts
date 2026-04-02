import { createI18n } from "vue-i18n"

import enAuth from "@/i18n/locales/en/auth.json"
import enCommon from "@/i18n/locales/en/common.json"
import enNav from "@/i18n/locales/en/nav.json"
import esAuth from "@/i18n/locales/es/auth.json"
import esCommon from "@/i18n/locales/es/common.json"
import esNav from "@/i18n/locales/es/nav.json"

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
    es: { ...esCommon, ...esAuth, ...esNav },
    en: { ...enCommon, ...enAuth, ...enNav },
  },
})

export default i18n
