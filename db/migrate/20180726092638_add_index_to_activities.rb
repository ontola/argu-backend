class AddIndexToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :root_id, :uuid

    Edge.connection.update('UPDATE activities SET "root_id" = edges.root_id FROM edges WHERE edges.uuid = activities.trackable_edge_id')
    Edge.connection.update('UPDATE activities SET "root_id" = edges.root_id FROM edges WHERE edges.uuid = activities.forum_id')

    rootless = Activity.where(root_id: nil)
    raise "#{rootless.count} without root_id left" if rootless.count > 400
    rootless.destroy_all

    change_column_null :activities, :root_id, false
    add_index :activities, :root_id
  end
end

