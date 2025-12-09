class AddAccountCodeToVoucherLines < ActiveRecord::Migration[7.1]
  def change
    add_column :voucher_lines, :account_code, :string, null: false, default: ""
    add_index :voucher_lines, :account_code
  end
end
