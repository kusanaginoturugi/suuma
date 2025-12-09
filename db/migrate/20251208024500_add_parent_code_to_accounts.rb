class AddParentCodeToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :parent_code, :string
    add_index :accounts, :parent_code
    add_foreign_key :accounts, :accounts, column: :parent_code, primary_key: :code
  end
end
