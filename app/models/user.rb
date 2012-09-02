class User < ActiveRecord::Base
  has_many :authentications
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable#, :omniauthable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :login
  # attr_accessible :title, :body

  has_settings

=begin
 before_save { |user| user.email = email.downcase }

  USERNAME_FORMAT_REGEX = /^\d*[a-zA-Z][a-zA-Z0-9]*$/i

  NAME_FORMAT_REGEX =  /^[a-z]{1,50}/i
  PASSWORD_FORMAT_REGEX = /^[a-z0-9_]{6,128}/i

  validates :username, presence: true,
		       length: { maximum:20, minimum: 3},
		       format: { with: USERNAME_FORMAT_REGEX },
		       uniqueness: { case_sensetive: false }
  validates :email,
		    format: { with: RFC822::EMAIL },
		    uniqueness: { case_sensetive: false }
  validates :name, allow_blank:true, format: { with: NAME_FORMAT_REGEX }
  validates :password,
		       length: { minimum: 6, maximum: 128 },
		       format: { with: PASSWORD_FORMAT_REGEX }
  validates :password_confirmation, presence: true, :if => lambda { new_record? || !password.blank? }
=end

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def email_required?
    (authentications.empty?) && super
  end

  #Provides username or email login
  def self.find_first_by_auth_conditions(warden_conditions)
    logger.debug "=================================================================================================================="
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions).first
      end
    end
end