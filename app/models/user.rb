class User < ActiveRecord::Base
  include ArguBase

  has_many :authentications, dependent: :destroy
  belongs_to :profile, dependent: :destroy

  accepts_nested_attributes_for :profile

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable#,
         #:validatable, :omniauthable

  before_create :check_for_profile
  after_destroy :cleanup
  before_save { |user| user.email = email.downcase unless email.blank? }
  before_save :normalize_blank_values

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login, :current_password, :email

  USERNAME_FORMAT_REGEX = /\A\d*[a-zA-Z][a-zA-Z0-9]*\z/i

  validates :username, presence: true,
           length: { in: 4..20 },
           format: { with: USERNAME_FORMAT_REGEX },
           uniqueness: { case_sensetive: false }
  validates :email, allow_blank: false,
        format: { with: RFC822::EMAIL }
  validates :profile_id, presence: true

#######Attributes########
  def display_name
    self.profile.name.presence || self.username
  end

  def web_url
    username
  end

#######Utility########
  def getLogin
    return (:username.blank? ? email : username )
  end

#########Auth##############
  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def email_required?
    (authentications.empty?) && super
  end

  def isOmniOnly
    authentications.any? && password.blank?
  end

  #######Methods########

  def self.isValidUsername?(name)
    USERNAME_FORMAT_REGEX.match(name.to_s)
  end

private
  def check_for_profile
    self.profile ||= Profile.create
  end

  def cleanup
    self.authentications.destroy_all
  end

  def normalize_blank_values
    attributes.each do |column, value|
      self[column].present? || self[column] = nil unless column.eql?(:roles) || column.eql?(:roles_mask)
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