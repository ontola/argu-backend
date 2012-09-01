class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :name, :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  has_settings

  before_save { |user| user.email = email.downcase }

  USERNAME_FORMAT_REGEX = /^[a-z0-9_-]/i
  NAME_FORMAT_REGEX =  /^[a-z]{1,50}/i
  PASSWORD_FORMAT_REGEX = /^[a-z0-9_]{6,128}/i

  validates :username, presence: true,
		       length: { maximum:20, minimum: 3},
		       format: { with: USERNAME_FORMAT_REGEX },
		       uniqueness: { case_sensetive: false }
  validates :email, presence: true,
		    format: { with: RFC822::EMAIL },
		    uniqueness: { case_sensetive: false }
  validates :name, allow_blank:true, format: { with: NAME_FORMAT_REGEX }
  validates :password,
		       length: { minimum: 6, maximum: 128 },
		       format: { with: PASSWORD_FORMAT_REGEX },
           presence: true, :if => lambda { new_record? || !password.blank? }
  validates :password_confirmation, presence: true, :if => lambda { new_record? || !password.blank? }
end
