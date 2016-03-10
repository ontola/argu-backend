class User < ActiveRecord::Base
  include ArguBase, Shortnameable, Flowable, Placeable

  has_one :profile, as: :profileable, dependent: :destroy, inverse_of: :profileable
  has_many :identities, dependent: :destroy
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  has_many :notifications
  has_one :home_placement, -> { where title: 'home', placeable_type: 'User' }, class_name: 'Placement', foreign_key: 'placeable_id', inverse_of: :placeable
  has_one :home_address, class_name: 'Place', through: :home_placement, source: :place
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

  enum follows_email: { never_follows_email: 0, weekly_follows_email: 1, direct_follows_email: 3 } # weekly_follows_email: 1, daily_follows_email: 2,
  #enum memberships_email: { never_memberships_email: 0, weekly_memberships_email: 1, daily_memberships_email: 2, direct_memberships_email: 3 }
  #enum created_email: { never_created_email: 0, weekly_created_email: 1, daily_created_email: 2, direct_created_email: 3 }

  validates :email, allow_blank: false,
        format: { with: RFC822::EMAIL }
  validates :profile, presence: true
  validates :language, inclusion: { in: I18n.available_locales.map(&:to_s), message: '%{value} is not a valid locale' }
  auto_strip_attributes :first_name, :last_name, :middle_name, :squish => true

  def active_at(redis = nil)
    Argu::Redis.get("user:#{self.id}:active.at", redis)
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
    if self.new_record? && new_attributes.include?(:access_tokens)
      self.shortname = nil if self.shortname.try(:shortname).blank?
    end
    super(new_attributes)
  end

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def country
    self.home_address.try(:country_code).try(:upcase) || 'NL'
  end


  def country=(value)
    @country = value.try(:downcase)
  end

  def display_name
    [self.first_name, self.middle_name, self.last_name].compact.join(' ').presence || self.url
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

  # Since we're the ones creating activities, we should select them based on us being the owner
  def flow
    Activity.where(owner: profile)
  end

  def greeting
    self.first_name.presence || self.url.presence || self.email.split('@').first
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
    Page.where(t[:id].in(self.profile.page_memberships.where(role: PageMembership.roles[:manager]).pluck(:page_id)).or(t[:owner_id].eq(self.profile.id)))
  end

  def password_required?
    (!persisted? && identities.blank?) || password.present? || password_confirmation.present?
  end

  def has_password?
    encrypted_password.present? || password.present? || password_confirmation.present?
  end

  def postal_code
    self.home_address.try(:postal_code)
  end

  def postal_code=(value)
    @postal_code = value.try(:upcase).try(:delete, ' ')
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
    Argu::Redis.set("user:#{self.id}:notification.count", self.notifications.count)
  end

  def update_acesss_token_counts
    if access_tokens.present?
      access_tokens = AccessToken.where(access_token: eval(self.access_tokens)).pluck :id
      AccessToken.increment_counter :sign_ups, access_tokens
    end
  end

  def validate_home_placement
    home_address
  end
  #
  # def home_placement=(val)
  #   update_attribute :home_placement, self.home_placement.find_or_initialize_by(val)
  # end

  # def update_home_address
  #   if self.country != @country || self.postal_code != @postal_code
  #     home_placement.destroy if home_placement.present?
  #     return if @country.blank? || @postal_code.blank?
  #     @place = Place.find_or_fetch_by(postcode: @postal_code, country_code: @country)
  #     build_home_placement(place: place, creator: profile) if place.present?
  #   end
  # end

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
