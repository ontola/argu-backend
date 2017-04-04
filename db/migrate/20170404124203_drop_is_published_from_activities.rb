class DropIsPublishedFromActivities < ActiveRecord::Migration[5.0]
  def change
    remove_column :activities, :is_published, :boolean, default: false, null: false
  end
end
