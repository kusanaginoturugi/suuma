import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "settingSelect",
    "bankAccountCode",
    "depositCounterCode",
    "withdrawalCounterCode",
    "dateColumn",
    "descriptionColumn",
    "depositColumn",
    "withdrawalColumn"
  ]

  load(event) {
    const option = event.target.selectedOptions[0]
    if (!option) return

    const payload = option.dataset.mapping ? JSON.parse(option.dataset.mapping) : null
    if (!payload) return

    this.bankAccountCodeTarget.value = payload.bank_account_code || ""
    this.depositCounterCodeTarget.value = payload.deposit_counter_code || ""
    this.withdrawalCounterCodeTarget.value = payload.withdrawal_counter_code || ""
    this.dateColumnTarget.value = payload.date_column || ""
    this.descriptionColumnTarget.value = payload.description_column || ""
    this.depositColumnTarget.value = payload.deposit_column || ""
    this.withdrawalColumnTarget.value = payload.withdrawal_column || ""
  }
}
