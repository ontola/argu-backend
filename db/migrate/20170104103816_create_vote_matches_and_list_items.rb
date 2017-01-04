class CreateVoteMatchesAndListItems < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp'

    create_table :vote_matches, id: :uuid do |t|
      t.string :shortname
      t.string :name, null: false
      t.text :text
      t.integer :publisher_id, null: false
      t.integer :creator_id, null: false
      t.timestamps
    end
    add_foreign_key :vote_matches, :profiles, column: :creator_id
    add_foreign_key :vote_matches, :users, column: :publisher_id

    create_table :list_items do |t|
      t.uuid :listable_id, null: false
      t.string :listable_type, null: false
      t.string :relationship, null: false
      t.integer :order, null: false
      t.string :iri, null: false
      t.string :resource_type, null: false
    end
  end
end
