class AddEdgeIdsToActivities < ActiveRecord::Migration[5.0]
  def up
    add_column :activities, :trackable_edge_id, :integer
    add_column :activities, :recipient_edge_id, :integer
    add_foreign_key :activities, :edges, column: :trackable_edge_id
    add_foreign_key :activities, :edges, column: :recipient_edge_id

    Activity.find_each do |activity|
      activity.update!(
        trackable_edge_id: Edge.where(owner_type: activity.trackable_type, owner_id: activity.trackable_id).ids.first,
        recipient_edge_id: Edge.where(owner_type: activity.recipient_type, owner_id: activity.recipient_id).ids.first
      )
    end
  end

  def down
    remove_column :activities, :trackable_edge_id
    remove_column :activities, :recipient_edge_id
  end
end
