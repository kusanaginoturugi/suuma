class VoucherLine < ApplicationRecord
  belongs_to :voucher

  before_validation :normalize_amounts

  validates :account, presence: true, allow_blank: false
  validate :amount_present

  private

  def normalize_amounts
    self.debit_amount = (debit_amount.presence || 0).to_d
    self.credit_amount = (credit_amount.presence || 0).to_d
  end

  def amount_present
    if debit_amount.to_d.zero? && credit_amount.to_d.zero?
      errors.add(:base, "借方または貸方の金額を入力してください")
    end
  end
end
