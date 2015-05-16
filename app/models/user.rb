class User < ActiveRecord::Base
  include ArguBase, Shortnameable

  has_many :authentications, dependent: :destroy
  has_one :profile, as: :profileable, dependent: :destroy

  accepts_nested_attributes_for :profile

  # Include default devise modules. Others available are:
  # :token_authenticatable,
  # :lockable, :timeoutable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]
         #, :confirmable#, :omniauthable
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  before_validation :check_for_profile
  after_destroy :cleanup
  after_create :update_acesss_token_counts
  before_save { |user| user.email = email.downcase unless email.blank? }

  attr_accessor :current_password, :repeat_name

  enum follows_email: { never_follows_email: 0, weekly_follows_email: 1, daily_follows_email: 2, direct_follows_email: 3 }
  enum memberships_email: { never_memberships_email: 0, weekly_memberships_email: 1, daily_memberships_email: 2, direct_memberships_email: 3 }
  enum created_email: { never_created_email: 0, weekly_created_email: 1, daily_created_email: 2, direct_created_email: 3 }

  validates :email, allow_blank: false,
        format: { with: RFC822::EMAIL }
  validates :profile, presence: true
  validates :first_name, :last_name, presence: true, length: {minimum: 1, maximum: 255}, if: :requires_name?

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

#######Attributes########
  def display_name
    [self.first_name, self.middle_name, self.last_name].compact.join(' ').presence || self.url
  end

  def profile
    super || create_profile
  end

  def managed_pages
    t = Page.arel_table
    Page.where(t[:id].in(self.profile.page_memberships.where(role: PageMembership.roles[:manager]).pluck(:page_id)).or(t[:owner_id].eq(self.profile.id)))
  end

#########Auth##############
  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def is_omni_only
    authentications.any? && password.blank?
  end

  #######Methods########
  def requires_name?
    finished_intro?
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

private
  def check_for_profile
    self.profile || self.create_profile
  end

  def cleanup
    self.authentications.destroy_all
    self.profile.activities.destroy_all
    self.profile.memberships.destroy_all
    self.profile.page_memberships.destroy_all
    self.profile.notifications.destroy_all
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

    def find_for_oauth(auth, signed_in_resource = nil)

      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)

      # If a signed_in_resource is provided it always overrides the existing user
      # to prevent the identity being locked with accidentally created accounts.
      # Note that this may leave zombie accounts (with no associated identity) which
      # can be cleaned up at a later date.
      user = signed_in_resource ? signed_in_resource : identity.user

      # Create the user if needed
      if user.nil?

        # Get the existing user by email if the provider gives us a verified email.
        # If no verified email was provided we assign a temporary email and ask the
        # user to verify it on the next step via UsersController.finish_signup
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        email = auth.info.email if email_is_verified
        user = User.where(:email => email).first if email

        # Create the user if it's a new registration
        if user.nil?
          user = User.new(
              first_name: auth.extra.raw_info.first_name,
              middle_name: auth.extra.raw_info.middle_name,
              last_name: auth.extra.raw_info.last_name,
              #username: auth.info.nickname || auth.uid,
              email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
              password: Devise.friendly_token[0,20]
          )
          # We're not yet confirming emails
          #user.skip_confirmation!
          user.save!
        end
      end

      # Associate the identity with the user if needed
      if identity.user != user
        identity.user = user
        identity.save!
      end
      user
    end
  end
end
