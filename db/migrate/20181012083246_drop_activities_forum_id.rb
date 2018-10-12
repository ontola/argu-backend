class DropActivitiesForumId < ActiveRecord::Migration[5.2]
  def change
    remove_column :activities, :forum_id
  end
end
