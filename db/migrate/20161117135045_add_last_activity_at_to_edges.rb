class AddLastActivityAtToEdges < ActiveRecord::Migration[5.0]
  def up
    add_column :edges, :last_activity_at, :datetime
    Edge.reset_column_information
    Edge.where(owner_type: %w(Vote Motion Argument Comment Forum Question BlogPost Project GroupResponse Decision)).find_each do |edge|
      last_activity = Activity
                        .where('(trackable_type = ? AND trackable_id = ?) OR (recipient_type = ? AND recipient_id = ? AND trackable_type != ?)',
                               edge.owner_type,
                               edge.owner_id,
                               edge.owner_type,
                               edge.owner_id,
                               'Vote')
                        .order(:created_at)
                        .last
      edge.update(last_activity_at: last_activity.created_at) if last_activity.present?
    end
  end

  def down
    remove_column :edges, :last_activity_at
  end
end
