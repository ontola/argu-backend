# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

raise 'NOMINATIM_KEY is empty, please edit your .env' if ENV['NOMINATIM_KEY'].nil?

load(Dir[Rails.root.join('db/seeds/doorkeeper_apps.seeds.rb')][0])

current_tenant = Apartment::Tenant.current
puts "Seeding #{current_tenant}" # rubocop:disable Rails/Output

if current_tenant == 'public'
  Apartment::Tenant.drop(:argu) if ApplicationRecord.connection.schema_exists?('argu')

  ActiveRecord::Base.transaction do
    Apartment::Tenant.switch('public') do
      Tenant.delete_all
      Tenant.create_system_users unless User.any?
    end
  end

  Tenant.setup_schema('argu', "#{Rails.application.config.host_name}/argu")
end

if current_tenant == 'argu'
  ActiveRecord::Base.transaction do
    staff =
      User
        .create!(
          email: 'staff@argu.co',
          shortname_attributes: {shortname: 'staff_account'},
          password: 'arguargu',
          password_confirmation: 'arguargu',
          first_name: 'Douglas',
          last_name: 'Engelbart',
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
      creator: User.find_via_shortname!('staff_account').profile,
      publisher: User.find_via_shortname!('staff_account'),
      parent: ActsAsTenant.current_tenant
    )
    forum.grants.new(group_id: Group::PUBLIC_ID, grant_set: GrantSet.participator)
    forum.save!
    forum.publish!

    Notification.update_all(read_at: nil) # rubocop:disable Rails/SkipsModelValidations
  end
end
