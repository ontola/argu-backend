class CreateTrashActivitiesWhereMissing < ActiveRecord::Migration[5.0]
  def up
    scope =
      Edge
        .where('trashed_at IS NOT NULL')
        .joins('LEFT JOIN activities ON activities.trackable_edge_id = edges.id AND activities.key  ~ \'*.trash\'')
        .where('activities.id IS NULL')
    scope
      .includes(:parent)
      .each do |edge|
      Activity.create!(
        trackable_id: edge.owner_id,
        trackable_type: edge.owner_type,
        forum_id: edge.owner.forum_id,
        owner_id: Profile::COMMUNITY_ID,
        owner_type: 'Profile',
        key: "#{edge.owner_type.underscore}.trash",
        recipient_id: edge.parent.owner_id,
        recipient_type: edge.parent.owner_type,
        created_at: edge.owner.updated_at,
        audit_data: {
          user_id: 0,
          user_name: '',
          recipient_id: "#{edge.owner_type}.#{edge.owner_id}",
          recipient_name: edge.owner.display_name,
          trackable_id: "#{edge.owner_type}.#{edge.owner_id}",
          trackable_name: edge.parent.owner.display_name,
          migration: '20170804070959'
        },
        trackable_edge_id: edge.id,
        recipient_edge_id: edge.parent.id
      )
    end
    raise "#{scope.count} trashed records without trash activity left" unless scope.count == 0
  end
end
