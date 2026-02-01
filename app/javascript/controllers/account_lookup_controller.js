import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["code", "name"]
  static values = { accountsMap: Object }

  connect() {
    this.entries = Object.entries(this.accountsMapValue || {})
  }

  update(event) {
    const input = event?.target
    const code = input ? input.value.trim() : this.codeTarget.value.trim()
    const name = this.lookup(code) || ""
    const nameTarget = input?.closest(".input-group")?.querySelector("[data-account-lookup-target='name']")
    if (nameTarget) {
      nameTarget.textContent = name
      return
    }
    if (this.hasNameTarget) this.nameTarget.textContent = name
    this.suggest(event)
  }

  lookup(code) {
    if (!code) return null
    return (this.accountsMapValue || {})[code] || null
  }

  suggest(event) {
    const input = event?.target
    if (!input) return
    const listId = input.getAttribute("list")
    if (!listId) return
    const datalist = document.getElementById(listId)
    if (!datalist) return

    const keyword = input.value.trim()
    const lower = keyword.toLowerCase()
    let matches = this.entries

    if (keyword) {
      matches = this.entries.filter(([code, name]) => {
        return code.startsWith(keyword) || name.toLowerCase().includes(lower)
      })
    }

    const limited = matches.slice(0, 10)
    datalist.innerHTML = limited
      .map(([code, name]) => `<option value="${this.escapeHtml(code)}">${this.escapeHtml(code)} ${this.escapeHtml(name)}</option>`)
      .join("")
  }

  escapeHtml(value) {
    return value.replace(/[&<>\"]/g, (char) => {
      switch (char) {
        case "&":
          return "&amp;"
        case "<":
          return "&lt;"
        case ">":
          return "&gt;"
        case "\"":
          return "&quot;"
        default:
          return char
      }
    })
  }
}
