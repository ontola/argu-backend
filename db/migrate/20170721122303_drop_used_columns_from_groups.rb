class DropUsedColumnsFromGroups < ActiveRecord::Migration[5.0]
  def up
    remove_column :groups, :forum_id
    remove_column :groups, :max_responses_per_member
    remove_column :groups, :icon
    remove_column :groups, :visibility
    remove_column :groups, :description
  end
end
