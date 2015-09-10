class RenameToCreator < ActiveRecord::Migration
  def up
    rename_column :access_tokens, :profile_id, :creator_id
    rename_column :comments, :profile_id, :creator_id
    rename_column :group_responses, :profile_id, :creator_id
  end

  def down
    rename_column :access_tokens, :creator_id, :profile_id
    rename_column :comments, :creator_id, :profile_id
    rename_column :group_responses, :creator_id, :profile_id
  end
end
