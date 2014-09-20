class User < ActiveRecord::Base
  rolify after_remove: :role_removed, before_add: :role_added
  has_many :authentications, dependent: :destroy
  has_many :votes, as: :voteable
  has_many :memberships, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :organisations, through: :memberships
  has_many :groups, through: :group_memberships
  has_one :profile, dependent: :destroy

  accepts_nested_attributes_for :profile

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
  attr_accessor :login, :current_password, :email, :_current_scope

  USERNAME_FORMAT_REGEX = /\A\d*[a-zA-Z][a-zA-Z0-9]*\z/i

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

#######Attributes########
  def display_name
    self.profile.name.presence || self.username
  end


#######Utility########
  def self.find(id)
    user = User.find_by_username(id.to_s)
    user ||= User.find_by_id(id)
    user ||= super(id)
  end
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

  def frozen?
    !has_role? 'user'
  end

  def freeze
    remove_role :user
  end

  def voted_on?(item)
    Vote.where(voter_id: self.id, voter_type: self.class.name,
                voteable_id: item.id, voteable_type: item.class.to_s).last
          .try(:for) == 'pro'
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