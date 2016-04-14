class ConvertActivityKeyToLtree < ActiveRecord::Migration
  def up
    enable_extension 'ltree'
    change_column :activities, :key, 'ltree USING key::ltree'
    add_index :activities, :key, using: :gist
  end

  def down
    disable_extension 'ltree'
    change_column :activities, :key, :string
  end
end
