class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string :model_type
      t.integer :model_id
      t.string :action
      t.string :role
      t.boolean :permit

      t.timestamps null: false
    end
  end
end
