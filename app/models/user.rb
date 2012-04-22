# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  username   :string(255)
#  email      :string(255)
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :username, :password, :password_confirmation
  has_secure_password

  before_save { |user| user.email = email.downcase }

  USERNAME_FORMAT_REGEX = /^[a-z0-9_-]/i
#  EMAIL_FORMAT_REGEX = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z]{2,6})$/i
  NAME_FORMAT_REGEX =  /^[a-z]{1,50}/i
  PASSWORD_FORMAT_REGEX = /^[a-z0-9_]{6,50}/i

  validates :username, presence: true,
		       length: { maximum:20, minimum: 3},
		       format: { with: USERNAME_FORMAT_REGEX },
		       uniqueness: { case_sensetive: false }
  validates :email, presence: true,
		    format: { with: RFC822::EMAIL },
		    uniqueness: { case_sensetive: false }
  validates :name, allow_blank:true, format: { with: NAME_FORMAT_REGEX }
  validates :password, presence: true,
		       length: { minimum: 6, maximum: 50 },
		       format: { with: PASSWORD_FORMAT_REGEX }
  validates :password_confirmation, presence: true

end
