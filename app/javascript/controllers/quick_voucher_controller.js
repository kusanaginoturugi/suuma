import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "amountDeposit",
    "amountWithdrawal",
    "depositButton",
    "withdrawalButton",
    "depositDescription",
    "withdrawalDescription",
  ]

  static values = { lastDirection: String }

  connect() {
    if (this.lastDirectionValue === "withdrawal") {
      this.withdrawalDescriptionTarget?.focus()
    } else if (this.lastDirectionValue === "deposit") {
      this.depositDescriptionTarget?.focus()
    }
  }

  submitDeposit(event) {
    if (event.key !== "Enter") return
    event.preventDefault()
    if (this.hasDepositButtonTarget) {
      this.element.requestSubmit(this.depositButtonTarget)
    }
  }

  submitWithdrawal(event) {
    if (event.key !== "Enter") return
    event.preventDefault()
    if (this.hasWithdrawalButtonTarget) {
      this.element.requestSubmit(this.withdrawalButtonTarget)
    }
  }
}
