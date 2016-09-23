class ConvertForumMembershipToFavorites < ActiveRecord::Migration[5.0]
  def up
    create_table :favorites do |t|
      t.integer :user_id, null: false
      t.integer :edge_id, null: false
      t.timestamps null: false
    end
    add_foreign_key :favorites, :edges
    add_foreign_key :favorites, :users
    add_index :favorites, [:user_id, :edge_id], unique: true

    # Create a favorite for all memberships of forum member groups
    memberships = GroupMembership
                    .includes(group: {grants: :edge}, profile: {})
                    .where(grants: {role: Grant.roles[:member]}, profiles: {profileable_type: 'User'})
                    .pluck('profiles.profileable_id, grants.edge_id')
                    .uniq
    Favorite.create!(memberships.map {|user_id, edge_id| {user_id: user_id, edge_id: edge_id}})
    unless Favorite.count == memberships.count
      raise "Missing #{memberships.count - Favorite.count} Favorites"
    end

    # Remove member groups of open forums
    Group
      .joins(grants: :edge)
      .where('groups.id > 0')
      .where(edges: {id: Forum.open.joins(:edge).pluck('edges.id')})
      .where(grants: {role: Grant.roles[:member]})
      .uniq
      .includes(:edge, group_memberships: {edge: [:grants, :follows, :favorites]})
      .destroy_all
  end

  def down
    drop_table :favorites
  end
end
