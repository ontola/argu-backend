class User < ActiveRecord::Base
  include ArguBase

  has_many :authentications, dependent: :destroy
  belongs_to :profile, dependent: :destroy, autosave: true

  accepts_nested_attributes_for :profile

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         #, :omniauthable

  before_validation :check_for_profile
  after_destroy :cleanup
  after_create :update_acesss_token_counts
  before_save { |user| user.email = email.downcase unless email.blank? }

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login, :current_password

  enum follows_email: { never_follows_email: 0, weekly_follows_email: 1, daily_follows_email: 2, direct_follows_email: 3 }
  enum memberships_email: { never_memberships_email: 0, weekly_memberships_email: 1, daily_memberships_email: 2, direct_memberships_email: 3 }
  enum created_email: { never_created_email: 0, weekly_created_email: 1, daily_created_email: 2, direct_created_email: 3 }

  USERNAME_FORMAT_REGEX = /\A\d*[a-zA-Z][_a-zA-Z0-9]*\z/i

  validates :username, presence: true,
           length: { in: 4..20 },
           format: { with: USERNAME_FORMAT_REGEX },
           uniqueness: { case_sensetive: false }
  validates :email, allow_blank: false,
        format: { with: RFC822::EMAIL }
  validates :profile, presence: true

#######Attributes########
  def display_name
    self.profile.name.presence || self.username
  end

  def profile
    super || create_profile
  end

  def managed_pages
    t = Page.arel_table
    Page.where(t[:id].eq(self.profile.page_memberships.where(role: PageMembership.roles[:manager]).pluck(:id)).or(t[:owner_id].eq(self.profile.id)))
  end

  def web_url
    username
  end

#########Auth##############
  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def is_omni_only
    authentications.any? && password.blank?
  end

  #######Methods########

  def self.is_valid_username?(name)
    USERNAME_FORMAT_REGEX.match(name.to_s)
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
    self.profile.update name: '', about: '', picture: '', profile_photo: '', cover_photo: ''
  end

  def self.find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions).first
      end
    end
end