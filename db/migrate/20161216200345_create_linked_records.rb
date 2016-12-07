class CreateLinkedRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :linked_records do |t|
      t.integer :page_id, null: false
      t.integer :source_id, null: false
      t.string :iri, null: false
      t.string :title
      t.timestamps
      t.index :iri, unique: true
      t.index [:iri, :source_id, :page_id]
    end
    add_foreign_key :linked_records, :pages
    add_foreign_key :linked_records, :sources
  end
end
