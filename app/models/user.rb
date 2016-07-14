class User < ActiveRecord::Base
  include ArguBase, Shortnameable, Flowable, Placeable

  has_one :home_address, class_name: 'Place', through: :home_placement, source: :place
  has_one :home_placement,
          -> { where title: 'home', placeable_type: 'User' },
          class_name: 'Placement',
          foreign_key: 'placeable_id',
          inverse_of: :placeable
  has_one :profile, as: :profileable, dependent: :destroy, inverse_of: :profileable
  has_many :edges
  has_many :identities, dependent: :destroy
  has_many :notifications
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :blog_posts, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :comments, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :group_responses, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :motions, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :projects, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :questions, inverse_of: :publisher, foreign_key: 'publisher_id'
  has_many :uploaded_photos, class_name: 'Photo', inverse_of: :publisher, foreign_key: 'publisher_id'
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :home_placement, reject_if: :all_blank

  # Include default devise modules. Others available are:
  # :token_authenticatable,
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [:facebook].freeze
  acts_as_follower

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  after_create :update_acesss_token_counts
  before_destroy :expropriate_dependencies
  before_save { |user| user.email = email.downcase unless email.blank? }

  attr_accessor :current_password, :repeat_name

  delegate :description, :member_of?, to: :profile

  enum reactions_email: {never_reactions_email: 0, weekly_reactions_email: 1, direct_reactions_email: 3}
  enum news_email: {never_news_email: 0, weekly_news_email: 1, direct_news_email: 3}
  enum decisions_email: {never_decisions_email: 0, weekly_decisions_email: 1, direct_decisions_email: 3}

  validates :email,
            allow_blank: false,
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
    email && email !~ TEMP_EMAIL_REGEX
  end

  # Since we're the ones creating activities, we should select them based on us being the owner
  def flow
    Activity.where(owner: profile)
  end

  # Creates a new follow record for this instance to follow the passed object.
  # Does not allow duplicate records to be created.
  def follow(followable, type = :reactions, ancestor_type = nil)
    if self != followable
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

  def greeting
    first_name.presence || url.presence || email.split('@').first
  end

  def is_omni_only
    authentications.any? && password.blank?
  end

  def last_email_sent_at(redis = nil)
    Argu::Redis.get("user:#{id}:email.sent.at", redis)
  end

  def managed_pages
    t = Page.arel_table
    Page.where(t[:id]
                 .in(profile.page_memberships.where(role: PageMembership.roles[:manager]).pluck(:page_id))
                 .or(t[:owner_id].eq(profile.id)))
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
    Hash[profile.email, profile.attributes.slice('id', 'name')]
  end

  protected

  def confirmation_required?
    false
  end

  private

  # Sets the dependent foreign relations to the Community profile
  def expropriate_dependencies
    %w(comments motions arguments questions blog_posts projects).each do |association|
      association
        .classify
        .constantize
        .expropriate(send(association))
    end
    Photo.expropriate(uploaded_photos)
    edges.update_all user_id: 0
  end

  def self.koala(auth)
    access_token = auth['token']
    facebook = Koala::Facebook::API.new(access_token)
    facebook.get_object('me')
  end

  class << self
    def serialize_from_session(key, salt)
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
