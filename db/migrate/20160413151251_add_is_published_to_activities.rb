class AddIsPublishedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :is_published, :boolean, default: false,  null: false
  end
end
