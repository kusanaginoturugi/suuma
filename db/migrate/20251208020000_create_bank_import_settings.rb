class CreateBankImportSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :bank_import_settings do |t|
      t.string :name, null: false
      t.string :bank_account_code, null: false
      t.string :deposit_counter_code, null: false
      t.string :withdrawal_counter_code, null: false
      t.string :date_column, null: false
      t.string :description_column, null: false
      t.string :deposit_column, null: false
      t.string :withdrawal_column, null: false

      t.timestamps
    end

    add_index :bank_import_settings, :name, unique: true
  end
end
