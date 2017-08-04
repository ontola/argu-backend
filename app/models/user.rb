# frozen_string_literal: true
class User < ApplicationRecord
  include Shortnameable, Placeable, Ldable, RedirectHelper

  before_destroy :expropriate_dependencies
  has_one :home_address, class_name: 'Place', through: :home_placement, source: :place
  has_one :home_placement,
          -> { where title: 'home' },
          class_name: 'Placement',
          as: :placeable,
          inverse_of: :placeable
  has_one :profile, as: :profileable, dependent: :destroy, inverse_of: :profileable
  has_many :edges
  has_many :emails, -> { order(primary: :desc) }, dependent: :destroy, inverse_of: :user
  has_many :favorites, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :notifications
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :blog_posts, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :comments, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :decisions, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :motions, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :projects, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :questions, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :votes, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :vote_events, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :vote_matches, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :uploaded_media_objects, class_name: 'MediaObject', inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :profile_vote_matches, through: :profile, source: :vote_matches
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :home_placement, reject_if: :all_blank
  accepts_nested_attributes_for :emails, reject_if: :all_blank, allow_destroy: true

  # Include default devise modules. Others available are:
  # :token_authenticatable,
  devise :multi_email_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :multi_email_validatable,
         :multi_email_confirmable, :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [:facebook].freeze
  acts_as_follower
  with_collection :vote_matches,
                  association: :profile_vote_matches,
                  pagination: true,
                  url_constructor: :user_vote_matches_url

  COMMUNITY_ID = 0
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  before_save :adjust_birthday, if: :birthday_changed?
  before_create :skip_confirmation_notification!
  before_create :build_public_group_membership
  after_commit :publish_data_event

  attr_accessor :current_password, :confirmation_string, :tab

  delegate :description, :member_of?, to: :profile

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

  contextualize_as_type 'schema:Person'
  contextualize_with_id { |m| Rails.application.routes.url_helpers.user_url(m.id, protocol: :https) }
  contextualize :display_name, as: 'schema:name'
  contextualize :about, as: 'schema:description'

  validates :profile, presence: true
  validates :language,
            inclusion: {
              in: I18n.available_locales.map(&:to_s),
              message: '%{value} is not a valid locale'
            }
  validate :r, :validate_r
  validate :validate_public_group_membership

  auto_strip_attributes :first_name, :last_name, :middle_name, squish: true

  def active_at(redis = nil)
    Argu::Redis.get("user:#{id}:active.at", redis)
  end

  def active_since?(datetime, redis = nil)
    active_at(redis).to_i >= datetime.to_i
  end

  def active_for_authentication?
    true
  end

  def apply_omniauth(omniauth)
    authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
  end

  def build_public_group_membership
    return if Group.public.nil?
    profile.group_memberships.build(
      member: profile,
      profile_id: Profile::COMMUNITY_ID,
      group_id: Group::PUBLIC_ID,
      start_date: DateTime.current
    )
  end

  def self.community
    User.find(User::COMMUNITY_ID)
  end

  def confirmed?
    emails.where('confirmed_at IS NOT NULL').any?
  end

  def create_confirmation_reminder_notification
    return if guest? || confirmed? || notifications.confirmation_reminder.any?
    Notification.confirmation_reminder.create(
      user: self,
      url: Rails.application.routes.url_helpers.settings_user_path(tab: :authentication),
      permanent: true,
      send_mail_after: 24.hours.from_now
    )
  end

  def display_name
    [first_name, middle_name, last_name].compact.join(' ').presence || url || I18n.t('users.no_shortname', id: id)
  end

  def draft_count
    Edge.where(user_id: id, is_published: false, owner_type: %w(Motion Question Project BlogPost)).count
  end

  # Creates a new follow record for this instance to follow the passed object.
  # Does not allow duplicate records to be created.
  def follow(followable, type = :reactions, ancestor_type = nil)
    return if self == followable
    if type.present?
      follow = follows.find_or_initialize_by(followable_id: followable.id,
                                             followable_type: parent_class_name(followable))
      follow.update(follow_type: type)
    end
    if ancestor_type.present?
      followable.ancestors.where(owner_type: %w(Motion Question Project Forum)).find_each do |ancestor|
        current_follow_type = following_type(ancestor)
        if Follow.follow_types[ancestor_type] > Follow.follow_types[current_follow_type]
          follow(ancestor, ancestor_type)
        end
      end
    end
    true
  end

  # The Follow for the followable by this User
  # @param [Edge] followable The Edge to find the Follow for
  # @return [Follow, nil]
  def follow_for(followable)
    Follow.unblocked.for_follower(self).for_followable(followable)&.first
  end

  # The follow_type for the followable
  # @param [Edge] followable The Edge to check the follow_type for
  # @return [String] the follow_type of the Follow for the followable by this User. 'never' if not following at all
  def following_type(followable)
    follow_for(followable).present? ? follow_for(followable).follow_type : 'never'
  end

  def favorite_forums
    Forum.joins(edge: :favorites).where('favorites.user_id = ?', id)
  end

  def favorite_forum_ids
    @favorite_forum_ids ||= favorite_forums.pluck(:id)
  end

  def greeting
    first_name.presence || url.presence || email.split('@').first
  end

  def guest?
    false
  end

  def forum_management?
    page_management? || profile.grants.manager.presence
  end

  def page_management?
    profile.pages.present?
  end

  def has_favorite?(edge)
    favorites.where(edge: edge).any?
  end

  def is_omni_only
    authentications.any? && password.blank?
  end

  def last_email_sent_at(redis = nil)
    Argu::Redis.get("user:#{id}:email.sent.at", redis)
  end

  # @return [ActiveRecord::Relation] The pages managed by the user
  def managed_pages
    return @managed_pages if @managed_pages.present?
    page_ids = profile.grants.page_manager.pluck('edges.owner_id')
    @managed_pages = page_ids.present? ? Page.where(id: page_ids) : Page.none
  end

  # Find profiles managed by the user, both its own profile as profiles of pages it manages
  # @return [ActiveRecord::Relation] The profiles managed by the user
  def managed_profiles
    @managed_profiles ||=
      if !confirmed? || managed_pages.empty?
        Profile.where(profileable_type: 'User', profileable_id: id)
      else
        Profile.where(
          '(profileable_type = ? AND profileable_id = ?) OR (profileable_type = ? AND profileable_id IN (?))',
          'User',
          id,
          'Page',
          managed_pages.pluck(:id)
        )
      end
  end

  # Find the ids of profiles managed by the user, both its own profile as profiles of pages it manages
  # @return [Array] The ids of the profiles managed by the user
  def managed_profile_ids
    @managed_profile_ids ||=
      if !confirmed? || managed_pages.empty?
        [profile.id]
      else
        managed_pages.joins(:profile).pluck('profiles.id').uniq.append(profile.id)
      end
  end

  def password_required?
    password.present? || password_confirmation.present?
  end

  def publish_data_event
    DataEvent.publish(self)
  end

  def has_password?
    encrypted_password.present? || password.present? || password_confirmation.present?
  end

  def requires_name?
    finished_intro?
  end

  def salt
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

  def sync_notification_count
    Argu::Redis.set("user:#{id}:notification.count", notifications.count)
  end

  def user_to_recipient_option
    Hash[profile.email, profile.attributes.slice('id', 'name')]
  end

  def validate_r
    return if valid_redirect?(r)
    errors.add(:r, "Redirecting to #{r} is not allowed")
  end

  def validate_public_group_membership
    profile.group_memberships.where(group_id: Group::PUBLIC_ID).present?
  end

  private

  # Sets the dependent foreign relations to the Community profile
  def expropriate_dependencies
    %w(comments motions arguments questions blog_posts projects votes vote_events vote_matches).each do |association|
      association
        .classify
        .constantize
        .expropriate(send(association))
    end
    emails.update_all(primary: false)
    MediaObject.expropriate(uploaded_media_objects)
    edges.update_all user_id: User::COMMUNITY_ID
  end

  def adjust_birthday
    self.birthday = Date.new(birthday.year, 7, 1) if birthday.present?
  end

  class << self
    def serialize_from_session(key, salt)
      record = to_adapter.get(key[0].to_param)
      record if record && record.authenticatable_salt == salt
    end

    def find_for_oauth(auth)
      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)
      identity&.user
    end

    private

    def koala(auth)
      access_token = auth['token']
      facebook = Koala::Facebook::API.new(access_token)
      facebook.get_object('me')
    end
  end
end
