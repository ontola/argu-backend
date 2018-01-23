class CreateExports < ActiveRecord::Migration[5.1]
  def change
    create_table :exports do |t|
      t.integer :user_id, null: false
      t.integer :edge_id, null: false
      t.integer :status, null: false, default: 0
      t.string :zip
      t.timestamps
    end

    add_foreign_key :exports, :users
    add_foreign_key :exports, :edges
  end
end
