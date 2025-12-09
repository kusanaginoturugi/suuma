class CreateImportRules < ActiveRecord::Migration[7.1]
  def change
    create_table :import_rules do |t|
      t.string :keyword, null: false
      t.string :account_code, null: false
      t.string :match_type, null: false, default: "contains"
      t.string :direction, null: false, default: "both" # deposit/withdrawal/both
      t.integer :priority, null: false, default: 100

      t.timestamps
    end

    add_index :import_rules, [:keyword, :direction]
    add_index :import_rules, :priority
  end
end
