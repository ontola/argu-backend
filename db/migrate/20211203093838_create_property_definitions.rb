class CreatePropertyDefinitions < ActiveRecord::Migration[6.1]
  def change
    create_table :property_definitions do |t|
      t.timestamps
      t.uuid :vocabulary_id, null: false
      t.string :predicate, null: false
      t.integer :property_type, null: false
      t.foreign_key :edges, column: :vocabulary_id, primary_key: :uuid, foreign_key: :vocabulary_id
    end
  end
end
