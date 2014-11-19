class ChangeOrgIdToForumId < ActiveRecord::Migration
  def change
    rename_column :questions, :organisation_id, :forum_id
  end
end
