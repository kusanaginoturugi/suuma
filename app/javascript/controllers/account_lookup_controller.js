import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["code", "name"]
  static values = { accountsMap: Object }

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
  }

  lookup(code) {
    if (!code) return null
    return (this.accountsMapValue || {})[code] || null
  }
}
