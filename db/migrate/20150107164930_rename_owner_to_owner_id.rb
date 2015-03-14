class RenameOwnerToOwnerId < ActiveRecord::Migration
  def change
    rename_column :pages, :owner, :owner_id
  end
end
