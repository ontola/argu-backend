# frozen_string_literal: true

require 'bcrypt'

class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance ConfirmedDestroyable
  enhance Placeable
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Indexable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Menuable

  has_one :profile, as: :profileable, dependent: :destroy, inverse_of: :profileable, primary_key: :uuid
  enhance ProfilePhotoable
  enhance CoverPhotoable

  include Broadcastable
  include RedirectHelper
  include Shortnameable
  include Uuidable
  include CacheableIri

  before_destroy :handle_dependencies
  has_one :home_address, class_name: 'Place', through: :home_placement, source: :place
  has_many :edges, dependent: :restrict_with_exception, foreign_key: :publisher_id, inverse_of: :publisher
  has_many :exports, dependent: :destroy
  has_many :email_addresses, -> { order(primary: :desc) }, dependent: :destroy, inverse_of: :user
  has_many :notifications, dependent: :destroy
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :blog_posts, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :comments, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :container_nodes, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :decisions, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :motions, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :pages, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :questions, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :topics, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :votes, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :vote_events, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :uploaded_media_objects,
           class_name: 'MediaObject',
           inverse_of: :publisher,
           foreign_key: 'publisher_id',
           dependent: :restrict_with_exception
  has_many :content_placements,
           -> { where(placement_type: %i[country custom]) },
           class_name: 'Placement',
           inverse_of: :publisher,
           foreign_key: 'publisher_id',
           dependent: :restrict_with_exception
  has_one :otp_secret, dependent: :destroy
  accepts_nested_attributes_for :email_addresses, reject_if: :all_blank, allow_destroy: true

  # Include default devise modules. Others available are:
  # :token_authenticatable,
  devise :multi_email_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :multi_email_validatable,
         :multi_email_confirmable, :lockable, :timeoutable
  acts_as_follower

  with_collection :managed_pages, association_class: Page
  with_collection :email_addresses

  placeable :home

  auto_strip_attributes :about, nullify: false

  COMMUNITY_ID = 0
  ANONYMOUS_ID = -1
  SERVICE_ID = -2
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/.freeze
  LOGIN_ATTRS = %w[updated_at failed_attempts].freeze
  FAILED_LOGIN_ATTRS = %w[current_sign_in_at last_sign_in_at sign_in_count updated_at].freeze

  before_save :adjust_birthday, if: :birthday_changed?
  before_create :skip_confirmation_notification!
  before_create :build_public_group_membership
  validates :about, length: {maximum: 3000}
  before_save :sanitize_redirect_url

  attr_accessor :current_password

  attribute :destroy_strategy, default: :expropriate_on_destroy

  enum destroy_strategy: {
    expropriate_on_destroy: 0,
    remove_on_destroy: 1
  }, _scopes: false
  enum reactions_email: {
    never_reactions_email: 0,
    weekly_reactions_email: 1,
    daily_reactions_email: 2,
    direct_reactions_email: 3
  }
  enum news_email: {never_news_email: 0, weekly_news_email: 1, daily_news_email: 2, direct_news_email: 3}
  enum decisions_email: {
    never_decisions_email: 0,
    weekly_decisions_email: 1,
    daily_decisions_email: 2,
    direct_decisions_email: 3
  }

  validates :profile, presence: true
  validates :language,
            inclusion: {
              in: I18n.available_locales.map(&:to_s),
              message: '%<value> is not a valid locale'
            }
  validate :validate_url_uniqueness

  auto_strip_attributes :first_name, :last_name, :middle_name, squish: true

  def self.find_for_database_authentication(warden_conditions)
    if warden_conditions[:email].include?('@')
      joins(:email_addresses).find_by('lower(email_addresses.email) = ?', warden_conditions[:email].downcase)
    else
      joins(:shortname).find_by('lower(shortnames.shortname) = ?', warden_conditions[:email].downcase)
    end
  end

  def accept_terms
    true if new_record?
  end

  def accept_terms=(val)
    return unless val.to_s == 'true'

    self.last_accepted = Time.current
    self.notifications_viewed_at = Time.current
  end

  def accepted_terms?
    last_accepted.present?
  end

  def active_for_authentication?
    true
  end

  def ancestor(_type); end

  def self.anonymous
    User.find(User::ANONYMOUS_ID)
  end

  def build_public_group_membership
    return if Group.public.nil?
    return if profile.group_memberships.any? { |m| m.group_id == Group::PUBLIC_ID }

    profile.group_memberships.build(
      member: profile,
      group_id: Group::PUBLIC_ID,
      start_date: Time.current
    )
  end

  def self.community
    User.find(User::COMMUNITY_ID)
  end

  def confirmed?
    @confirmed ||= email_addresses.where('confirmed_at IS NOT NULL').any?
  end

  def create_confirmation_reminder_notification(root_id)
    return if guest? || confirmed? || notifications.confirmation_reminder.any?

    Notification.confirmation_reminder.create(
      user: self,
      url: menu(:profile).iri(fragment: :settings),
      permanent: true,
      root_id: root_id,
      send_mail_after: 24.hours.from_now
    )
  end

  def create_finish_intro_notification
    return if setup_finished? || notifications.finish_intro.any?

    Notification.finish_intro.create(
      user: self,
      url: Rails.application.routes.url_helpers.setup_users_path,
      permanent: true
    )
  end

  def display_name
    real_name || url || generated_name
  end
  alias name display_name

  def enforce_hidden_last_name!
    update!(hide_last_name: true)
  end

  # Creates a new {Follow} or updates an existing one, except when a higher follow or a never follow is present.
  # Follows the ancestors if #ancestor_type is given.
  def follow(followable, type = :reactions, ancestor_type = nil)
    return if self == followable || !accepted_terms?

    follow_resource(followable, type) if type.present?
    follow_ancestors(followable, ancestor_type) if ancestor_type.present?

    true
  end

  # The Follow for the followable by this User
  # @param [Edge] followable The Edge to find the Follow for
  # @return [Follow, nil]
  def follow_for(followable)
    Follow.unblocked.for_follower(self).find_by(followable_id: followable.uuid, followable_type: 'Edge')
  end

  # The follow_type for the followable
  # @param [Edge] followable The Edge to check the follow_type for
  # @return [String] the follow_type of the Follow for the followable by this User. 'never' if not following at all
  def following_type(followable)
    follow_for(followable)&.follow_type || 'never'
  end

  def favorite_pages # rubocop:disable Metrics/MethodLength
    return Page.none if guest?

    @favorite_pages ||=
      ActsAsTenant.without_tenant do
        pids = page_ids + profile.groups.pluck('distinct root_id')
        Kaminari.paginate_array(
          Page
            .joins(:profile)
            .order('profiles.name')
            .where(uuid: pids)
            .includes(:shortname, :tenant, :default_profile_photo)
            .to_a
        )
      end
  end

  def generated_name
    [I18n.t('groups.public.name_singular'), id].join(' ') unless new_record?
  end

  def guest?
    false
  end

  def forum_management?
    page_management? || profile.grants.moderator.presence
  end

  def iri_opts
    {id: url || id}
  end

  def is_staff?
    @is_staff ||= profile.is_group_member?(Group::STAFF_ID)
  end

  # @return [ActiveRecord::Relation] The pages managed by the user
  def managed_pages
    @managed_pages ||=
      Page
        .joins(grants: {group: :group_memberships, grant_set: :permitted_actions})
        .where(group_memberships: {member_id: profile.id}, permitted_actions: {resource_type: 'Page', action: 'update'})
        .distinct
  end

  # Find the ids of profiles managed by the user, both its own profile as profiles of pages it manages
  # @return [Array] The ids of the profiles managed by the user
  def managed_profile_ids
    @managed_profile_ids ||=
      if !confirmed? || managed_pages.blank?
        [profile.id]
      else
        managed_pages.joins(:profile).pluck('profiles.id').uniq.append(profile.id)
      end
  end

  def otp_active?
    otp_secret&.active?
  end

  def otp_secret
    super || OtpSecret.create!(user: self)
  end

  def page_collection(options)
    @page_collection ||= ::Collection.new(
      options.merge(
        association_base: favorite_pages,
        association_class: Page,
        default_type: :paginated,
        parent: self
      )
    )
  end

  def page_count
    @page_count ||= ActsAsTenant.without_tenant { edges.where(owner_type: 'Page').length }
  end

  def page_ids
    @page_ids ||= ActsAsTenant.without_tenant { edges.where(owner_type: 'Page').pluck(:uuid) }
  end

  def page_management?
    page_count.positive?
  end

  def password_required?
    password.present? || password_confirmation.present?
  end

  def previous_changes
    changes = super
    if changes.include?('encrypted_password')
      changes['has_pass'] = [
        changes['encrypted_password'].first.present?,
        changes['encrypted_password'].second.present?
      ]
    end
    changes
  end

  def has_password?
    encrypted_password.present? || password.present? || password_confirmation.present?
  end

  def real_name
    [first_name, middle_name, (!hide_last_name && last_name).presence].compact.join(' ').presence
  end

  def requires_2fa?
    profile.groups.where(require_2fa: true).any? if profile
  end

  def reserved?
    id <= 0
  end

  def salt # rubocop:disable Metrics/AbcSize
    if encrypted_password.presence
      ::BCrypt::Password.new(encrypted_password).salt
    else
      salt = Argu::Redis.get("user:#{id}:salt")
      if salt.blank?
        salt = ::BCrypt::Engine.generate_salt(Rails.application.config.devise.stretches)
        Argu::Redis.set("user:#{id}:salt", salt)
      end
      salt.presence || ::BCrypt::Engine.generate_salt(Rails.application.config.devise.stretches)
    end
  end

  def send_devise_notification(notification, *args) # rubocop:disable Metrics/MethodLength
    case notification
    when :reset_password_instructions
      SendEmailWorker.perform_async(
        notification,
        id,
        token_url: iri_from_template(:user_set_password, reset_password_token: args.first)
      )
    when :unlock_instructions
      SendEmailWorker
        .perform_async(notification, id, token_url: iri_from_template(:user_unlock, unlock_token: args.first))
    else
      raise "Trying to send a Devise #{notification} mail"
    end
  end

  def send_reset_password_token_email
    token = set_reset_password_token
    SendEmailWorker
      .perform_async(:set_password, id, token_url: iri_from_template(:user_set_password, reset_password_token: token))
  end

  def self.service
    User.find(User::SERVICE_ID)
  end

  def service?
    id == User::SERVICE_ID
  end

  def setup_finished?
    (url || first_name).present?
  end

  private

  def adjust_birthday
    return if birthday.blank?

    self.birthday = Date.new(birthday.year, 7, 1)
    self.hide_last_name = true if minor?
  end

  def dependent_associations
    (Edge.descendants.map(&:to_s).map(&:tableize) + %w[uploaded_media_objects content_placements])
  end

  def destroy_dependencies
    dependent_associations.each do |association|
      try(association)&.destroy_all
    end
  end

  # Sets the dependent foreign relations to the Community profile
  def expropriate_dependencies
    dependent_associations.each do |association|
      try(association)
        &.model
        &.expropriate(try(association))
    end
  end

  def follow_ancestors(followable, ancestor_type)
    followable.ancestors.where(owner_type: self.class.followable_classes).find_each do |ancestor|
      follow(ancestor, ancestor_type)
    end
  end

  def follow_resource(followable, follow_type)
    follow = follows.find_or_initialize_by(
      followable_id: followable.uuid,
      followable_type: 'Edge'
    )
    lower = Follow.follow_types[follow_type] <= Follow.follow_types[follow.follow_type]

    return if follow.persisted? && (follow.never? || lower)

    follow.update!(follow_type: follow_type)
  end

  def handle_dependencies
    remove_on_destroy? ? destroy_dependencies : expropriate_dependencies

    email_addresses.update_all(primary: false) # rubocop:disable Rails/SkipsModelValidations
  end

  def minor?
    birthday && (Date.current.year - birthday.year) <= 18
  end

  def sanitize_redirect_url
    self.redirect_url = nil unless argu_iri_or_relative?(redirect_url)
  end

  def should_broadcast_changes
    keys = previous_changes.keys
    return true if keys.length != LOGIN_ATTRS.length && keys.length != FAILED_LOGIN_ATTRS.length

    !(keys & LOGIN_ATTRS == keys || keys & FAILED_LOGIN_ATTRS == keys) # rubocop:disable Style/MultipleComparison
  end

  def validate_url_uniqueness
    shortname&.errors&.each do |_key, message|
      errors.add(:url, message)
    end
    errors[:'shortname.shortname'].clear
  end

  class << self
    def followable_classes
      @followable_classes ||= Edge.descendants.select { |klass| klass.enhanced_with?(Followable) }.freeze.map(&:to_s)
    end

    def preview_includes
      %i[
        default_profile_photo
        email_addresses
      ]
    end

    def serialize_from_session(key, salt)
      record = to_adapter.get(key[0].to_param)
      record if record && record.authenticatable_salt == salt
    end

    def iri
      NS::SCHEMA[:Person]
    end
  end
end
