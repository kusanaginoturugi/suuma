class BankImportSetting < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :bank_account_code, :deposit_counter_code, :withdrawal_counter_code, presence: true
end
