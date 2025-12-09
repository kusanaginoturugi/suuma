class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :category, null: false

      t.timestamps
    end

    add_index :accounts, :code, unique: true
    add_index :accounts, :category
  end
end
