class DropIdReferencesFromActivities < ActiveRecord::Migration[6.0]
  def change
    remove_column :activities, :recipient_id
    remove_column :activities, :trackable_id
  end
end
