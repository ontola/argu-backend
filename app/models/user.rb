class User < ActiveRecord::Base
  rolify after_remove: :role_removed, before_add: :role_added
  has_many :authentications, dependent: :destroy
  has_many :avotes, as: :voteable
  has_one :profile, dependent: :destroy

  accepts_nested_attributes_for :profile
  acts_as_voter

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable#,
         #:validatable, :omniauthable

  before_create :check_for_profile
  before_create :mark_as_user
  after_destroy :cleanup
  before_save { |user| user.email = email.downcase unless email.blank? }
  before_save :normalize_blank_values

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login, :current_password, :email

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :username, :profile, :email, :password, :password_confirmation,
  #                :remember_me, :unconfirmed_email, :provider, :uid, :login,
  #                :role, :current_password

  USERNAME_FORMAT_REGEX = /\A\d*[a-zA-Z][a-zA-Z0-9]*\z/i
  NAME_FORMAT_REGEX =  /\A[a-z]{1,50}/i
  PASSWORD_FORMAT_REGEX = /\A[a-z0-9_]{6,128}/i

  validates :username, presence: true,
           length: { in: 4..20 },
           format: { with: USERNAME_FORMAT_REGEX },
           uniqueness: { case_sensetive: false }
  validates :email, allow_blank: true,
        format: { with: RFC822::EMAIL }

  searchable do 
    text :username, :email
  end
  handle_asynchronously :solr_index
  handle_asynchronously :solr_index!
  handle_asynchronously :remove_from_index

#general
  def self.find(id)
    user = User.find_by_username(id.to_s)
    user ||= User.find_by_id(id)
    user ||= super(id)
  end
  def getLogin
    return (:username.blank? ? email : username )
  end

#authentiaction
  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def email_required?
    (authentications.empty?) && super
  end

  def isOmniOnly
    authentications.any? && password.blank?
  end

  def self.isValidUsername?(name)
    USERNAME_FORMAT_REGEX.match(name.to_s)
  end

  def frozen?
    !has_role? 'user'
  end

  def freeze
    remove_role :user
  end

  def unfreeze
    add_role :user
  end

private
  def check_for_profile
    self.profile ||= Profile.create
  end

  def cleanup
    self.authentications.destroy_all
  end

  def mark_as_user
    self.add_role :user
  end

  def normalize_blank_values
    attributes.each do |column, value|
      self[column].present? || self[column] = nil unless column.eql?(:roles) || column.eql?(:roles_mask)
    end
  end

  def role_added(role)
    if self.frozen?
      # Send mail or notification to user that he has been unfrozen
    end
  end

  def role_removed(role)
    if self.frozen?
      # Send mail or notification to user that he has been frozen
    end
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