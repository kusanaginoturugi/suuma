import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "amountDeposit",
    "amountWithdrawal",
    "depositButton",
    "withdrawalButton",
    "recordedOn",
  ]

  connect() {
    if (this.hasRecordedOnTarget) {
      this.recordedOnTarget.focus()
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
