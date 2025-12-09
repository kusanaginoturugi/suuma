class VoucherLine < ApplicationRecord
  belongs_to :voucher
  belongs_to :account_master, class_name: "Account", primary_key: :code, foreign_key: :account_code, optional: true

  before_validation :normalize_amounts
  before_validation :sync_account_name

  validates :account_code, presence: true
  validates :account, presence: true
  validate :account_exists
  validate :amount_present

  private

  def normalize_amounts
    self.debit_amount = (debit_amount.presence || 0).to_d
    self.credit_amount = (credit_amount.presence || 0).to_d
  end

  def sync_account_name
    return if account_code.blank?
    self.account_master = Account.find_by(code: account_code)
    self.account = account_master&.name
  end

  def account_exists
    errors.add(:account_code, "が科目表に存在しません") if account_code.present? && account_master.nil?
  end

  def amount_present
    if debit_amount.to_d.zero? && credit_amount.to_d.zero?
      errors.add(:base, "借方または貸方の金額を入力してください")
    end
  end
end
