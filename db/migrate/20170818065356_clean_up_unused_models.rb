class CleanUpUnusedModels < ActiveRecord::Migration[5.1]
  def change
    drop_table :memberships
    drop_table :group_responses
    Notification
      .joins(activity: :trackable_edge)
      .where(edges: {owner_type: %w(Group GroupMembership Membership GroupResponse)})
      .delete_all
    Activity
      .joins(:trackable_edge)
      .where(edges: {owner_type: %w(Group GroupMembership Membership GroupResponse)})
      .delete_all
    Follow
      .joins(:followable)
      .where(edges: {owner_type: %w(Group GroupMembership Membership GroupResponse)})
      .delete_all
    Edge
      .where(owner_type: %w(GroupMembership Membership GroupResponse))
      .delete_all
    Edge
      .where(owner_type: %w(Group))
      .delete_all
  end
end
