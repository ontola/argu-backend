class ConvertAccessTokensToGroupMemberships < ActiveRecord::Migration[5.0]
  def up
    User.where('access_tokens IS NOT NULL AND access_tokens != ?', '[]').find_each do |user|
      eval(user.access_tokens).each do |at|
        token = AccessToken.find_by(access_token: at)
        if token.present? && token.item.visible_with_a_link && !token.item.open?
          group = token.item.edge.grants.member.first&.group ||
            token.item.page.edge.grants.member.first&.group
          if group.present? && GroupMembership.find_by(member: user.profile, group: group).nil?
            service = CreateGroupMembership.new(
              group.edge,
              attributes: {member: user.profile, profile: user.profile},
              options: {publisher: user, creator: user.profile}
            )
            service.on(:create_group_membership_failed) do |gm|
              raise gm.errors.full_messages
            end
            service.commit
          end
        end
      end
    end
  end
end
