class AddHasHeaderToBankImportSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :bank_import_settings, :has_header, :boolean, null: false, default: true
  end
end
