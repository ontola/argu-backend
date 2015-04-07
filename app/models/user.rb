class User < ActiveRecord::Base
  include ArguBase, Shortnameable

  has_many :authentications, dependent: :destroy
  has_one :profile, as: :profileable, dependent: :destroy

  #accepts_nested_attributes_for :profile

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

  attr_accessor :current_password, :repeat_name

  enum follows_email: { never_follows_email: 0, weekly_follows_email: 1, daily_follows_email: 2, direct_follows_email: 3 }
  enum memberships_email: { never_memberships_email: 0, weekly_memberships_email: 1, daily_memberships_email: 2, direct_memberships_email: 3 }
  enum created_email: { never_created_email: 0, weekly_created_email: 1, daily_created_email: 2, direct_created_email: 3 }

  validates :email, allow_blank: false,
        format: { with: RFC822::EMAIL }
  validates :profile, presence: true
  validates :first_name, :last_name, presence: true, length: {minimum: 1, maximum: 255}, if: :requires_name?

  # @private
  # Note: Fix for devise_invitable w/ shortnameable
  # Override deletes the shortname if
  # shortname is blank, user is a new record and the attributes include access_token
  #
  # The combination of the three is assumed to correctly identify an {User} record
  # created by devise_invitable
  def assign_attributes(new_attributes)
    if self.new_record? && new_attributes.include?(:access_tokens)
      self.shortname = nil if self.shortname.try(:shortname).blank?
    end
    super(new_attributes)
  end

#######Attributes########
  def display_name
    [self.first_name, self.middle_name, self.last_name].compact.join(' ') || self.url
  end

  def profile
    super || create_profile
  end

  def managed_pages
    t = Page.arel_table
    Page.where(t[:id].in(self.profile.page_memberships.where(role: PageMembership.roles[:manager]).pluck(:page_id)).or(t[:owner_id].eq(self.profile.id)))
  end

#########Auth##############
  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def is_omni_only
    authentications.any? && password.blank?
  end

  #######Methods########
  def requires_name?
    finished_intro?
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
    self.profile.notifications.destroy_all
  end

end