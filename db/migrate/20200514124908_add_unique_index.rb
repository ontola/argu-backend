class AddUniqueIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :groups, %i[root_id name], unique: true
    add_index :groups, %i[root_id name_singular], unique: true
  end
end
