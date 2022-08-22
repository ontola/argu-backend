# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ActiveRecord::Base.transaction do
  Tenant.seed_schema('argu', "#{Rails.application.config.host_name}/argu")

  staff =
    User
      .create!(
        email: 'staff@example.com',
        password: 'password',
        password_confirmation: 'password',
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

  ActsAsTenant.current_tenant.forums.first.grants.create!(group_id: Group::PUBLIC_ID, grant_set: GrantSet.initiator)
  forum = Forum.new(
    name: 'Private',
    root_id: ActsAsTenant.current_tenant.root_id,
    url: 'private',
    creator: staff.profile,
    publisher: staff,
    parent: ActsAsTenant.current_tenant
  )
  forum.save!
  forum.publish!

  Notification.update_all(read_at: nil) # rubocop:disable Rails/SkipsModelValidations
end
