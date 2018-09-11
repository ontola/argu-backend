class RenamePageIdToRootId < ActiveRecord::Migration[5.2]
  def change
    rename_column :groups, :page_id, :root_id
    rename_column :grant_sets, :page_id, :root_id
  end
end
