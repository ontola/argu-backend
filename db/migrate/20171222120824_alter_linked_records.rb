class AlterLinkedRecords < ActiveRecord::Migration[5.1]
  def change
    LinkedRecord.destroy_all

    remove_column :linked_records, :page_id
    remove_column :linked_records, :source_id
    remove_column :linked_records, :record_iri
    remove_column :linked_records, :record_type
    remove_column :linked_records, :title

    add_column :linked_records, :deku_id, :uuid, null: false

    add_index :linked_records, :deku_id, unique: true
  end
end
