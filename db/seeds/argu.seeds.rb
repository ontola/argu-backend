ActiveRecord::Base.transaction do
  Tenant.setup_schema('argu', "#{Rails.application.config.host_name}/argu")

  Apartment::Tenant.switch!('argu') do
    staff =
      User
        .create!(
          email: 'staff@argu.co',
          password: 'arguargu',
          password_confirmation: 'arguargu',
          display_name: 'Douglas Engelbart',
          profile: Profile.new,
          last_accepted: Time.current
        )

    staff_membership =
      CreateGroupMembership.new(
        Group.staff,
        attributes: {member: staff.profile},
        options: {user_context: UserContext.new(user: staff, profile: staff.profile)}
      ).resource
    staff_membership.save!(validate: false)

    ActsAsTenant.current_tenant = Page.argu

    forum = Forum.new(
      name: 'Nederland',
      initial_public_grant: 'participator',
      root_id: ActsAsTenant.current_tenant.root_id,
      url: 'nederland',
      creator: staff.profile,
      publisher: staff,
      parent: ActsAsTenant.current_tenant
    )
    forum.grants.new(group_id: Group::PUBLIC_ID, grant_set: GrantSet.participator)
    forum.save!
    forum.publish!

    Notification.update_all(read_at: nil) # rubocop:disable Rails/SkipsModelValidations
  end
end
