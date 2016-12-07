class CreateSources < ActiveRecord::Migration[5.0]
  def change
    create_table :sources do |t|
      t.string :name, null: false
      t.integer :page_id, null: false
      t.string :iri_base, null: false
      t.integer :creator_id, null: false
      t.integer :publisher_id, null: false
      t.integer :visibility, default: 3
      t.string :shortname, null: false
      t.timestamps
      t.index :iri_base, unique: true
      t.index [:page_id, :shortname], unique: true
    end
    add_foreign_key :sources, :pages
    add_foreign_key :sources, :profiles, column: :creator_id
    add_foreign_key :sources, :users, column: :publisher_id
  end
end
