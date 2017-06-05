class CreatePublicGroupMemberships < ActiveRecord::Migration[5.0]
  def up
    public_group = Group.public
    Profile
      .where(profileable_type: 'User')
      .pluck(:id)
      .map do |profile_id|
        GroupMembership.create!(
          member_id: profile_id,
          group_id: Group::PUBLIC_ID,
          profile_id: Profile::COMMUNITY_ID,
          edge: Edge.new(parent: public_group.edge, user_id: User::COMMUNITY_ID)
        )
    end
  end

  def down
    GroupMembership.where(group_id: Group::PUBLIC_ID).destroy_all
  end
end
