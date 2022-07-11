# frozen_string_literal: true

class Tenant < ApplicationRecord # rubocop:disable Metrics/ClassLength
  IRI_PREFIX_BLACKLIST = [
    Rails.application.config.host_name,
    "#{Rails.application.config.host_name}/"
  ].freeze

  has_one :page, foreign_key: :uuid, primary_key: :root_id, inverse_of: :tenant, dependent: false
  validates :iri_prefix, exclusion: {in: IRI_PREFIX_BLACKLIST}
  after_update :reset_iri_prefix, if: :iri_prefix_previously_changed?

  def host
    iri_prefix.split('/').first
  end

  def path
    iri_prefix.split('/')[1..].join('/')
  end

  private

  def reset_iri_prefix
    Page.update_iris(iri_prefix_previous_change.first, iri_prefix_previous_change.second, root_id: root_id)
  end

  class << self
    def create_system_users
      create_system_user(User::COMMUNITY_ID, Profile::COMMUNITY_ID, 'community', 'community@argu.co')
      create_system_user(User::SERVICE_ID, Profile::SERVICE_ID, 'service', 'service_user@argu.co')
      create_system_user(User::ANONYMOUS_ID, Profile::ANONYMOUS_ID, 'anonymous', 'anonymous@argu.co')
      create_system_user(User::GUEST_ID, Profile::GUEST_ID, 'guest', 'guest@argu.co')
    end

    def setup_schema(name, iri_prefix, page_url = nil)
      Apartment::Tenant.create(name) unless ApplicationRecord.connection.schema_exists?(name)
      seed_schema(name, iri_prefix, page_url)
    end

    def seed_schema(name, iri_prefix, page_url = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      Apartment::Tenant.switch(name) do
        load(Dir[Rails.root.join('db/seeds/grant_sets.seeds.rb')][0])
        create_system_users

        first_page = create_first_page(page_url || name, iri_prefix)

        create_system_group(Group::PUBLIC_ID, 'Public', 'Public', first_page)
        create_system_group(Group::STAFF_ID, 'Staff', 'Staff', first_page)

        first_page.send(:create_staff_grant)

        create_system_group_membership(Group.public, User.community, Profile.community)
        create_system_group_membership(Group.public, User.guest, Profile.guest)

        first_page
      end
    end

    def with_tenant_fallback(&block)
      return yield if ActsAsTenant.current_tenant.present?

      with_schema_fallback do
        ActsAsTenant.with_tenant(Page.argu, &block)
      end
    end

    private

    def create_first_page(name, iri_prefix) # rubocop:disable Metrics/MethodLength
      page = Page.create!(
        active_branch: true,
        publisher_id: User::SERVICE_ID,
        creator_id: Profile::SERVICE_ID,
        profile: Profile.new,
        name: name.humanize,
        url: name,
        is_published: true,
        iri_prefix: iri_prefix
      )
      page.tenant.update!(database_schema: Apartment::Tenant.current)
      ActsAsTenant.current_tenant = page
    end

    def create_system_group(id, plural, singular, page)
      public_group = Group.new(
        id: id,
        name: plural,
        name_singular: singular,
        page: page
      )
      public_group.save!(validate: false)
      public_group
    end

    def create_system_group_membership(group, user, profile)
      group_membership =
        CreateGroupMembership.new(
          group,
          attributes: {member_id: profile.id},
          options: {user_context: UserContext.new(user: user, profile: profile)}
        ).resource
      group_membership.save!(validate: false)
      group_membership
    end

    def create_system_user(user_id, profile_id, name, email) # rubocop:disable Metrics/MethodLength
      profile =
        Profile.new(
          id: profile_id,
          profileable:
            User
              .new(
                last_accepted: Time.current,
                id: user_id,
                display_name: name,
                email: email,
                password: SecureRandom.hex(32)
              )
        )
      profile.save!(validate: false)
      profile.profileable.update_column(:encrypted_password, '') # rubocop:disable Rails/SkipsModelValidations
      profile
    end

    def with_schema_fallback(&block)
      yield unless Apartment::Tenant.current == 'public'

      Apartment::Tenant.switch('argu', &block)
    end
  end
end
