class RenameProfileIdToCreatorId < ActiveRecord::Migration
  def change
    rename_column :comments, :profile_id, :creator_id
    rename_column :group_responses, :profile_id, :creator_id
  end
end
