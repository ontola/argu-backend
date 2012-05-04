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
require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessible :email, :name, :username, :password, :password_confirmation, :clearance

  has_secure_password
  has_settings
  has_restful_permissions
  
  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  before_save { :clearance.nil? ? 4 : :clearance }

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
  validates :clearance, presence: true, allow_blank: false

  def user_creatable_by?(creating_user)
    if !creating_user.nil?
      puts "---------------------"+creating_user.clearance.to_s+"-------------------" + self.clearance.to_s
      case self.clearance
      when 0
        false
      when 1
        Settings['permissions.create.administrator'] >= creating_user.clearance unless creating_user.clearance.nil?
      when 2
        Settings['permissions.create.moderator'] >= creating_user.clearance unless creating_user.clearance.nil?
      when 3
        Settings['permissions.create.trusted'] >= creating_user.clearance unless creating_user.clearance.nil?
      when 4
        true
      when 6..8
        true
        #TODO: special user policies
      else
        false
      end
    elsif creating_user.nil?
      Settings['permissions.create.user'] >= self.clearance
    end
  end

  def updatable_by?(user)
    Settings['permissions.update.user'] >= user.clearance  unless user.clearance.nil? || :id == self.id
  end
  def destroyable_by?(user)
    Settings['permissions.destroy.user'] >= user.clearance  unless user.clearance.nil? || :id == self.id
  end

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
