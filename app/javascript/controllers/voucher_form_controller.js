import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rows", "rowTemplate", "totalDebit", "totalCredit", "difference", "balanceBadge"]

  connect() {
    this.nextIndex = parseInt(this.rowsTarget.dataset.nextIndex || this.rowsTarget.children.length, 10)
    this.recalculate()
  }

  addRow() {
    const html = this.rowTemplateTarget.innerHTML.replace(/__INDEX__/g, this.nextIndex)
    this.nextIndex += 1
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
    this.recalculate()
    const lastRow = this.rowsTarget.lastElementChild
    lastRow?.querySelector("input")?.focus()
  }

  removeRow(event) {
    const row = event.target.closest("[data-voucher-form-target='row']")
    if (!row) return

    if (this.rowsTarget.children.length <= 1) {
      row.querySelectorAll("input").forEach((input) => (input.value = ""))
    } else {
      row.remove()
    }
    this.recalculate()
  }

  recalculate() {
    let debit = 0
    let credit = 0

    this.rowsTarget.querySelectorAll('input[name$="[debit_amount]"]').forEach((input) => {
      debit += this.valueToNumber(input.value)
    })

    this.rowsTarget.querySelectorAll('input[name$="[credit_amount]"]').forEach((input) => {
      credit += this.valueToNumber(input.value)
    })

    const difference = debit - credit

    this.totalDebitTarget.textContent = this.formatAmount(debit)
    this.totalCreditTarget.textContent = this.formatAmount(credit)
    this.differenceTarget.textContent = this.formatAmount(difference)
    this.updateBadge(difference)
  }

  updateBadge(difference) {
    const balanced = Math.abs(difference) < 0.005
    this.balanceBadgeTarget.textContent = balanced ? "バランスOK" : "調整してください"
    this.balanceBadgeTarget.classList.toggle("badge--ok", balanced)
    this.balanceBadgeTarget.classList.toggle("badge--warn", !balanced)
  }

  valueToNumber(value) {
    const number = parseFloat(value)
    return Number.isFinite(number) ? number : 0
  }

  formatAmount(value) {
    return value.toLocaleString("ja-JP", { minimumFractionDigits: 0, maximumFractionDigits: 2 })
  }
}
