# This migration comes from simple_settings (originally 20150108155439)
class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string  :key
      t.text    :value
    end
    add_index :settings, :key, unique: true
  end
end
