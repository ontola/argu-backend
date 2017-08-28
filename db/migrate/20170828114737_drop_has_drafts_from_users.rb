class DropHasDraftsFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :has_drafts
  end
end
