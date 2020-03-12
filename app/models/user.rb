# frozen_string_literal: true

require 'bcrypt'

class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance ConfirmedDestroyable
  enhance Placeable
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Updatable
  enhance Settingable
  enhance LinkedRails::Enhancements::Menuable

  has_one :profile, as: :profileable, dependent: :destroy, inverse_of: :profileable, primary_key: :uuid
  enhance ProfilePhotoable
  enhance CoverPhotoable

  include Broadcastable
  include RedirectHelper
  include Shortnameable
  include Uuidable
  include CacheableIri

  before_destroy :expropriate_dependencies
  has_one :home_address, class_name: 'Place', through: :home_placement, source: :place
  has_many :edges, dependent: :restrict_with_exception, foreign_key: :publisher_id, inverse_of: :publisher
  has_many :email_addresses, -> { order(primary: :desc) }, dependent: :destroy, inverse_of: :user
  has_many :favorites, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :blog_posts, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :comments, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :decisions, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :motions, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :questions, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :votes, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :vote_events, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :employments, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :restrict_with_exception
  has_many :uploaded_media_objects,
           class_name: 'MediaObject',
           inverse_of: :publisher,
           foreign_key: 'publisher_id',
           dependent: :restrict_with_exception
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

  attr_accessor :current_password

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
  validate :r, :validate_r
  validate :validate_public_group_membership

  auto_strip_attributes :first_name, :last_name, :middle_name, squish: true

  def self.find_for_database_authentication(warden_conditions)
    if warden_conditions[:email].include?('@')
      joins(:email_addresses).find_by('lower(email_addresses.email) = ?', warden_conditions[:email])
    else
      joins(:shortname).find_by('lower(shortnames.shortname) = ?', warden_conditions[:email])
    end
  end

  def accept_terms!(skip_set_password_mail = false)
    update!(last_accepted: Time.current, notifications_viewed_at: Time.current)
    return true if skip_set_password_mail || encrypted_password.present?

    send_reset_password_token_email

    true
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
      url: settings_iri('/u', tab: :authentication),
      permanent: true,
      root_id: root_id,
      send_mail_after: 24.hours.from_now
    )
  end

  def create_finish_intro_notification
    return if url.present? || notifications.finish_intro.any?

    Notification.finish_intro.create(
      user: self,
      url: Rails.application.routes.url_helpers.setup_users_path,
      permanent: true
    )
  end

  def display_name
    [first_name, middle_name, (!hide_last_name && last_name).presence].compact.join(' ').presence ||
      url ||
      [I18n.t('groups.public.name_singular'), id].join(' ')
  end
  alias name display_name

  def enforce_hidden_last_name!
    update!(hide_last_name: true)
  end

  # Creates a new {Follow} or updates an existing one, except when a higher follow or a never follow is present.
  # Follows the ancestors if #ancestor_type is given.
  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def follow(followable, type = :reactions, ancestor_type = nil)
    return if self == followable || !accepted_terms?

    if type.present?
      follow = follows.find_or_initialize_by(followable_id: followable.uuid,
                                             followable_type: 'Edge')
      if follow.new_record? || (!follow.never? && Follow.follow_types[type] > Follow.follow_types[follow.follow_type])
        follow.update!(follow_type: type)
      end
    end
    if ancestor_type.present?
      followable.ancestors.where(owner_type: %w[Motion Question Forum Page]).find_each do |ancestor|
        follow(ancestor, ancestor_type)
      end
    end
    true
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

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

  def favorite_forums
    @favorite_forums ||=
      Forum
        .joins(:favorites)
        .where('favorites.user_id = ?', id)
        .order(Favorite.arel_table[:created_at].asc)
        .includes(:properties)
  end

  def favorite_forum_ids
    @favorite_forum_ids ||= favorite_forums.pluck(:id)
  end

  def favorite_pages
    return Page.none if guest?

    @favorite_pages ||=
      ActsAsTenant.without_tenant do
        pids = favorite_forums.joins(:parent).pluck('parents_edges.uuid') + page_ids
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

  def guest?
    false
  end

  def forum_management?
    page_management? || profile.grants.moderator.presence
  end

  def has_favorite?(edge)
    favorites.where(edge: edge).any?
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

  def page_collection(options)
    @page_collection ||= ::Collection.new(
      options.merge(
        association_base: favorite_pages,
        association_class: Page,
        default_type: :paginated,
        parent: self,
        title: I18n.t('pages.my_pages')
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

  def send_devise_notification(notification, *args)
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

  def sync_notification_count
    Argu::Redis.set("user:#{id}:notification.count", notifications.count)
  end

  def validate_r
    return if argu_iri_or_relative?(r)

    errors.add(:r, "Redirecting to #{r} is not allowed")
  end

  def validate_public_group_membership
    profile&.group_memberships&.where(group_id: Group::PUBLIC_ID)&.present?
  end

  private

  def adjust_birthday
    return if birthday.blank?

    self.birthday = Date.new(birthday.year, 7, 1)
    self.hide_last_name = true if minor?
  end

  # Sets the dependent foreign relations to the Community profile
  def expropriate_dependencies
    %w[comments motions arguments questions blog_posts votes vote_events uploaded_media_objects]
      .each do |association|
      send(association)
        .model
        .expropriate(send(association))
    end
    # rubocop:disable Rails/SkipsModelValidations
    email_addresses.update_all(primary: false)
    edges.update_all(publisher_id: User::COMMUNITY_ID, creator_id: Profile::COMMUNITY_ID)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def minor?
    birthday && (Date.current.year - birthday.year) <= 18
  end

  def should_broadcast_changes
    keys = previous_changes.keys
    return true if keys.length != LOGIN_ATTRS.length && keys.length != FAILED_LOGIN_ATTRS.length

    !(keys & LOGIN_ATTRS == keys || keys & FAILED_LOGIN_ATTRS == keys) # rubocop:disable Style/MultipleComparison
  end

  class << self
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
