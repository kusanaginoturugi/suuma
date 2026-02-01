import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["code", "name"]
  static values = { accountsMap: Object }

  update() {
    const code = this.codeTarget.value.trim()
    const name = this.lookup(code)
    this.nameTarget.textContent = name || ""
  }

  lookup(code) {
    if (!code) return null
    return (this.accountsMapValue || {})[code] || null
  }
}
