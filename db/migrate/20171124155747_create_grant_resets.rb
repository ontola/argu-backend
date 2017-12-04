class CreateGrantResets < ActiveRecord::Migration[5.1]
  def change
    create_table :grant_resets do |t|
      t.integer :edge_id, null: false
      t.string :resource_type, null: false
      t.string :action, null: false
      t.index [:edge_id, :resource_type, :action], unique: true
    end
    add_foreign_key :grant_resets, :edges
  end
end
