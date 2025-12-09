class Voucher < ApplicationRecord
  has_many :voucher_lines, dependent: :destroy

  accepts_nested_attributes_for :voucher_lines, allow_destroy: true, reject_if: :blank_line?

  before_validation :apply_defaults

  validates :recorded_on, presence: true
  validates :voucher_number, presence: true
  validate :at_least_one_line
  validate :balanced_entries

  def total_debit
    voucher_lines.sum { |line| line.debit_amount.to_d }
  end

  def total_credit
    voucher_lines.sum { |line| line.credit_amount.to_d }
  end

  def balance_difference
    total_debit - total_credit
  end

  private

  def apply_defaults
    self.recorded_on ||= Date.current
    self.voucher_number = default_number if voucher_number.blank?
  end

  def default_number
    Date.current.strftime("%Y%m%d-001")
  end

  def blank_line?(attrs)
    attrs.slice(:account, :debit_amount, :credit_amount, :note).values.all?(&:blank?)
  end

  def at_least_one_line
    errors.add(:base, "明細を1行以上入力してください") if voucher_lines.reject(&:marked_for_destruction?).empty?
  end

  def balanced_entries
    return if voucher_lines.empty?
    errors.add(:base, "借方と貸方の合計が一致していません") unless balance_difference.zero?
  end
end
