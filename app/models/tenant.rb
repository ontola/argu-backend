# frozen_string_literal: true

class Tenant < ApplicationRecord
  IRI_PREFIX_BLACKLIST = [
    Rails.application.config.host_name,
    "#{Rails.application.config.host_name}/"
  ].freeze

  has_one :page, foreign_key: :uuid, primary_key: :root_id, inverse_of: :tenant, dependent: false
  validates :iri_prefix, exclusion: {in: IRI_PREFIX_BLACKLIST}
  after_update :reset_iri_prefix, if: :iri_prefix_previously_changed?
  after_destroy :clean_manifest

  def host
    iri_prefix.split('/').first
  end

  def path
    iri_prefix.split('/')[1..].join('/')
  end

  private

  def clean_manifest
    Manifest.destroy(page.iri)
  end

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

    def seed_schema(name, iri_prefix)
      load(Dir[Rails.root.join('db/seeds/grant_sets.seeds.rb')][0])
      create_system_users

      ActsAsTenant.current_tenant = create_first_page(name, iri_prefix)
    end

    def with_tenant_fallback(&block)
      return yield if ActsAsTenant.current_tenant.present?

      ActsAsTenant.with_tenant(Page.argu, &block)
    end

    private

    def create_first_page(name, iri_prefix)
      Page.create!(
        active_branch: true,
        publisher_id: User::SERVICE_ID,
        creator_id: Profile::SERVICE_ID,
        profile: Profile.new,
        name: name.humanize,
        url: name,
        is_published: true,
        iri_prefix: iri_prefix
      )
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
  end
end
