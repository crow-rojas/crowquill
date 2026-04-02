import { afterAll, afterEach, beforeEach } from "vitest"

const warningPatterns = [
  /KaTeX doesn't work in quirks mode/i,
  /Vue received a Component that was made a reactive object/i,
]

const originalWarn = console.warn.bind(console)
const originalError = console.error.bind(console)

function normalizeMessage(args: unknown[]) {
  return args
    .map((arg) => {
      if (typeof arg === "string") return arg
      if (arg instanceof Error) return arg.message
      try {
        return JSON.stringify(arg)
      } catch {
        return String(arg)
      }
    })
    .join(" ")
}

function throwIfBlockedWarning(args: unknown[]) {
  const message = normalizeMessage(args)
  const pattern = warningPatterns.find((regex) => regex.test(message))

  if (pattern) {
    throw new Error(`Unexpected test warning matched ${pattern}: ${message}`)
  }
}

function ensureDoctype() {
  if (typeof document === "undefined") return
  if (document.doctype) return

  const doctype = document.implementation.createDocumentType("html", "", "")
  document.insertBefore(doctype, document.documentElement)
}

function forceStandardsMode() {
  if (typeof document === "undefined") return

  if (document.compatMode === "CSS1Compat") return

  try {
    Object.defineProperty(document, "compatMode", {
      configurable: true,
      get: () => "CSS1Compat",
    })
  } catch {
    // Ignore: if compatMode is not configurable, doctype is still applied.
  }
}

// Apply once at setup load so import-time KaTeX checks see standards mode.
ensureDoctype()
forceStandardsMode()

console.warn = (...args: unknown[]) => {
  throwIfBlockedWarning(args)
  originalWarn(...args)
}

console.error = (...args: unknown[]) => {
  throwIfBlockedWarning(args)
  originalError(...args)
}

beforeEach(() => {
  ensureDoctype()
  forceStandardsMode()
})

afterEach(() => {
  if (typeof document === "undefined") return

  document.head.innerHTML = ""
  document.body.innerHTML = ""
})

afterAll(() => {
  console.warn = originalWarn
  console.error = originalError
})
