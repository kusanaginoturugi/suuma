class CreateVouchers < ActiveRecord::Migration[7.1]
  def change
    create_table :vouchers do |t|
      t.date :recorded_on, null: false
      t.string :voucher_number, null: false
      t.string :description

      t.timestamps
    end

    add_index :vouchers, :voucher_number, unique: true

    create_table :voucher_lines do |t|
      t.references :voucher, null: false, foreign_key: true
      t.string :account, null: false
      t.decimal :debit_amount, precision: 15, scale: 2, default: 0, null: false
      t.decimal :credit_amount, precision: 15, scale: 2, default: 0, null: false
      t.string :note

      t.timestamps
    end
  end
end
