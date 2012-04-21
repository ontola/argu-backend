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
  attr_accessible :email, :name, :username

  USERNAME_FORMAT_REGEX = /^[a-z0-9_-]{3,20}/
  validates :username, presence: true, format: { with: USERNAME_FORMAT_REGEX }, uniqueness: { case_sensetive: false }
#  EMAIL_FORMAT_REGEX = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/
  EMAIL_FORMAT_REGEX = /^\A[\w+\-.]+@/
  validates :email, presence: true, format: { with: EMAIL_FORMAT_REGEX }, uniqueness: { case_sensetive: false }
#, with: RFC822::EMAIL
  before_save { |user| user.email = email.downcase }
end
