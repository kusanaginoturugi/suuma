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
    const toDark = this.buttonTarget.dataset.themeToggleLightLabel || this.buttonTarget.dataset.themeToggleDarkLabel || "ダークモードに切替"
    const toLight = this.buttonTarget.dataset.themeToggleDarkLabel || this.buttonTarget.dataset.themeToggleLightLabel || "ライトモードに切替"
    this.buttonTarget.textContent = theme === THEMES.light ? toDark : toLight
  }

  validTheme(value) {
    return Object.values(THEMES).includes(value)
  }
}
