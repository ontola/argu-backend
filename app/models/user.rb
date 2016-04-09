class User < ActiveRecord::Base
  include ArguBase, Shortnameable, Flowable, Placeable

  has_one :profile, as: :profileable, dependent: :destroy, inverse_of: :profileable
  has_many :identities, dependent: :destroy
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  has_many :notifications
  has_one :home_placement, -> { where title: 'home', placeable_type: 'User' }, class_name: 'Placement', foreign_key: 'placeable_id', inverse_of: :placeable
  has_one :home_address, class_name: 'Place', through: :home_placement, source: :place
  # User content
  has_many :arguments, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :nullify
  has_many :blog_posts, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :nullify
  has_many :comments, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :nullify
  has_many :group_responses, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :nullify
  has_many :motions, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :nullify
  has_many :projects, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :nullify
  has_many :questions, inverse_of: :publisher, foreign_key: 'publisher_id', dependent: :nullify
  accepts_nested_attributes_for :profile, :home_placement

  # Include default devise modules. Others available are:
  # :token_authenticatable,
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [:facebook].freeze
  acts_as_follower

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  after_destroy :cleanup
  after_create :update_acesss_token_counts
  before_save { |user| user.email = email.downcase unless email.blank? }

  attr_accessor :current_password, :repeat_name

  delegate :description, to: :profile

  enum follows_email: {ever_follows_email: 0, weekly_follows_email: 1, direct_follows_email: 3} # weekly_follows_email: 1, daily_follows_email: 2,
  # enum memberships_email: {never_memberships_email: 0, weekly_memberships_email: 1, daily_memberships_email: 2, direct_memberships_email: 3}
  # enum created_email: {never_created_email: 0, weekly_created_email: 1, daily_created_email: 2, direct_created_email: 3}

  validates :email, allow_blank: false,
        format: {with: RFC822::EMAIL}
  validates :profile, presence: true
  validates :language,
            inclusion: {
              in: I18n.available_locales.map(&:to_s),
              message: '%{value} is not a valid locale'
            }
  auto_strip_attributes :first_name, :last_name, :middle_name, squish: true

  def active_at(redis = nil)
    Argu::Redis.get("user:#{id}:active.at", redis)
  end

  def active_since?(datetime, redis = nil)
    active_at(redis).to_i >= datetime.to_i
  end

  # @private
  # Note: Fix for devise_invitable w/ shortnameable
  # Override deletes the shortname if
  # shortname is blank, user is a new record and the attributes include access_token
  #
  # The combination of the three is assumed to correctly identify an {User} record
  # created by devise_invitable
  def assign_attributes(new_attributes)
    if new_record? && new_attributes.include?(:access_tokens)
      self.shortname = nil if shortname.try(:shortname).blank?
    end
    super(new_attributes)
  end

  def apply_omniauth(omniauth)
    authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
  end

  def display_name
    [first_name, middle_name, last_name].compact.join(' ').presence || url
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

  # Since we're the ones creating activities, we should select them based on us being the owner
  def flow
    Activity.where(owner: profile)
  end

  def greeting
    first_name.presence || url.presence || email.split('@').first
  end

  def home_placement
    super || build_home_placement(creator: self.profile)
  end

  def is_omni_only
    authentications.any? && password.blank?
  end

  def last_email_sent_at(redis = nil)
    Argu::Redis.get("user:#{self.id}:email.sent.at", redis)
  end

  def managed_pages
    t = Page.arel_table
    Page.where(t[:id].in(self.profile.page_memberships.where(role: PageMembership.roles[:manager]).pluck(:page_id)).or(t[:owner_id].eq(profile.id)))
  end

  def password_required?
    (!persisted? && identities.blank?) || password.present? || password_confirmation.present?
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

  def update_acesss_token_counts
    if access_tokens.present?
      access_tokens = AccessToken.where(access_token: eval(self.access_tokens)).pluck :id
      AccessToken.increment_counter :sign_ups, access_tokens
    end
  end

  def user_to_recipient_option
    Hash[self.profile.email, self.profile.attributes.slice('id', 'name')]
  end

  protected

  def confirmation_required?
    false
  end

private
  def cleanup
    self.identities.destroy_all
    self.profile.activities.destroy_all
    self.profile.memberships.destroy_all
    self.profile.page_memberships.destroy_all
  end

  def self.koala(auth)
    access_token = auth['token']
    facebook = Koala::Facebook::API.new(access_token)
    facebook.get_object('me')
  end

  class << self
    def serialize_from_session(key,salt)
      record = to_adapter.get(key[0].to_param)
      record if record && record.authenticatable_salt == salt
    end

    def find_for_oauth(auth)
      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)
      identity && identity.user
    end
  end
end
