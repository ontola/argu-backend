# frozen_string_literal: true

require 'bcrypt'

class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance ConfirmedDestroyable
  enhance Placeable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance Feedable
  enhance Grantable
  enhance Searchable

  has_one :profile, as: :profileable, dependent: :destroy, inverse_of: :profileable, primary_key: :uuid
  enhance ProfilePhotoable
  enhance CoverPhotoable

  include Broadcastable
  include RedirectHelper
  include Uuidable

  before_destroy :handle_dependencies
  placeable :home
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
  has_one :otp_secret, dependent: :destroy, foreign_key: :owner_id, inverse_of: :owner
  accepts_nested_attributes_for :email_addresses, reject_if: :all_blank, allow_destroy: true

  # Include default devise modules. Others available are:
  # :token_authenticatable,
  devise :multi_email_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :multi_email_validatable,
         :multi_email_confirmable, :lockable, :timeoutable
  acts_as_follower

  with_collection :email_addresses
  with_collection :favorite_pages,
                  association_class: Page,
                  default_filters: {},
                  policy_scope: false
  with_collection :search_results,
                  association_class: User,
                  collection_class: SearchResult::Collection

  auto_strip_attributes :about, nullify: false

  COMMUNITY_ID = 0
  ANONYMOUS_ID = -1
  SERVICE_ID = -2
  GUEST_ID = -3
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/.freeze
  LOGIN_ATTRS = %w[updated_at failed_attempts].freeze
  FAILED_LOGIN_ATTRS = %w[current_sign_in_at last_sign_in_at sign_in_count updated_at].freeze

  before_save :adjust_birthday, if: :birthday_changed?
  before_create :build_public_group_membership
  validates :about, length: {maximum: 3000}
  before_save :sanitize_redirect_url

  attr_accessor :current_password, :session_id

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

  auto_strip_attributes :display_name, squish: true
  alias_attribute :name, :display_name

  def accept_terms=(val)
    return unless val.to_s == 'true'

    self.last_accepted = Time.current
    self.notifications_viewed_at = Time.current
  end

  def accepted_terms?
    last_accepted.present?
  end
  alias accepted_terms accepted_terms?
  alias accept_terms accepted_terms?

  def active_for_authentication?
    true
  end

  def ancestor(_type); end

  def build_public_group_membership
    return if Group.public.nil?
    return if profile.group_memberships.any? { |m| m.group_id == Group::PUBLIC_ID }

    profile.group_memberships.build(
      member: profile,
      group_id: Group::PUBLIC_ID,
      start_date: Time.current
    )
  end

  def confirmed?
    @confirmed ||= email_addresses.where('confirmed_at IS NOT NULL').any?
  end

  def create_confirmation_reminder_notification(root_id)
    return if guest? || confirmed? || notifications.confirmation_reminder.any?

    Notification.confirmation_reminder.create(
      user: self,
      url: menu(:settings).iri(fragment: :settings),
      permanent: true,
      root_id: root_id,
      send_mail_after: 24.hours.from_now
    )
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
    id == GUEST_ID
  end

  def identifier
    return "users_#{id}" unless guest? && session_id

    "sessions_#{session_id}"
  end

  def is_staff?
    @is_staff ||= profile.is_group_member?(Group::STAFF_ID)
  end

  def name_with_fallback
    display_name || generated_name
  end

  def otp_active?
    otp_secret&.active?
  end

  def otp_secret
    super || OtpSecret.create!(owner: self)
  end

  def page_count
    @page_count ||= ActsAsTenant.without_tenant { edges.where(owner_type: 'Page').length }
  end

  def page_ids
    @page_ids ||= ActsAsTenant.without_tenant { edges.where(owner_type: 'Page').pluck(:uuid) }
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

  def requires_2fa?
    profile.groups.where(require_2fa: true).any? if profile
  end

  def reserved?
    id <= 0
  end

  # Include email in search data. User search is only available for staff.
  def search_data
    data = super
    data[:email] = email
    data
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

  def service?
    id == User::SERVICE_ID
  end

  def searchable_should_index?
    edges.where(root_id: ActsAsTenant.current_tenant.uuid).any?
  end

  private

  def adjust_birthday
    return if birthday.blank?

    self.birthday = Date.new(birthday.year, 7, 1)
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

  def sanitize_redirect_url
    self.redirect_url = nil unless argu_iri_or_relative?(redirect_url)
  end

  def should_broadcast_changes
    keys = previous_changes.keys
    return true if keys.length != LOGIN_ATTRS.length && keys.length != FAILED_LOGIN_ATTRS.length

    !(keys & LOGIN_ATTRS == keys || keys & FAILED_LOGIN_ATTRS == keys) # rubocop:disable Style/MultipleComparison
  end

  class << self
    def anonymous
      User.find(User::ANONYMOUS_ID)
    end

    def build_new(parent: nil, user_context: nil)
      resource = super
      resource.build_profile
      resource.language = I18n.locale
      resource
    end

    def community
      User.find(User::COMMUNITY_ID)
    end

    def find_for_database_authentication(warden_conditions)
      joins(:email_addresses).find_by('lower(email_addresses.email) = ?', warden_conditions[:email].downcase)
    end

    def followable_classes
      @followable_classes ||= Edge.descendants.select { |klass| klass.enhanced_with?(Followable) }.freeze.map(&:to_s)
    end

    def from_identifier(identifier)
      split = identifier.split('_')
      case split.first
      when 'sessions'
        User.guest(split.second)
      else
        User.find(split.second)
      end
    end

    def guest(session_id = nil, language = nil)
      user = User.find(User::GUEST_ID)
      user.session_id = session_id
      user.language = language || ActsAsTenant.current_tenant&.language
      user
    end

    def preview_includes
      %i[
        default_profile_photo
        email_addresses
      ]
    end

    def requested_single_resource(params, user_context)
      # @todo Remove shortname check (https://gitlab.com/ontola/core/-/issues/741)
      resource = (/[a-zA-Z]/i =~ params[:id]).present? ? Shortname.find_resource(params[:id]) : super

      show_anonymous_user = user_context&.guest? && resource.present? && !resource.is_public?
      return AnonymousUser.new(id: params[:id]) if show_anonymous_user

      resource
    end

    def requested_singular_resource(_params, user_context)
      user_context.user
    end

    def route_key
      :u
    end

    def service
      User.find(User::SERVICE_ID)
    end

    def singular_route_key
      :user
    end

    def iri
      NS.schema.Person
    end
  end
end
