class AddDetailsToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :details, :text
  end
end
