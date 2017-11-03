class RenameIRIColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :linked_records, :iri, :record_iri
    rename_column :list_items, :iri, :item_iri
    rename_column :list_items, :resource_type, :item_type
  end
end
