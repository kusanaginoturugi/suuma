import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "summa-theme"
const THEMES = { light: "light", dark: "dark" }

export default class extends Controller {
  static targets = ["button"]

  connect() {
    const saved = window.localStorage.getItem(STORAGE_KEY)
    const initial = this.validTheme(saved) ? saved : THEMES.light
    this.applyTheme(initial)
  }

  toggle() {
    const current = document.documentElement.dataset.theme || THEMES.light
    const next = current === THEMES.light ? THEMES.dark : THEMES.light
    this.applyTheme(next)
  }

  applyTheme(theme) {
    document.documentElement.dataset.theme = theme
    document.body.dataset.theme = theme
    window.localStorage.setItem(STORAGE_KEY, theme)
    this.updateButtonLabel(theme)
  }

  updateButtonLabel(theme) {
    if (!this.hasButtonTarget) return
    this.buttonTarget.textContent = theme === THEMES.light ? "ダークモードに切替" : "ライトモードに切替"
  }

  validTheme(value) {
    return Object.values(THEMES).includes(value)
  }
}
