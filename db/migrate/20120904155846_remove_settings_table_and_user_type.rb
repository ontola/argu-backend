class RemoveSettingsTableAndUserType < ActiveRecord::Migration
  def up
  	drop_table :settings
  end

  def down
  	create_table :settings, :force => true do |t|
    	t.string  :var,         :null => false
    	t.text    :value
    	t.integer :target_id
    	t.string  :target_type, :limit => 30
    	t.timestamps
  	end
    add_column :users, :clearance, :int
  end
end
