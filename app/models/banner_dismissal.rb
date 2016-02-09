class BannerDismissal
  include ActiveModel::Dirty, ActiveModel::Model, ActiveModel::Validations
  include StubbornCookie

  attr_accessor :banner, :user
  define_attribute_methods :banner, :user

  validates :banner, :user, presence: true

  def banner=(value)
    banner_will_change!
    @banner = value
  end

  def banner_id=(value)
    banner_will_change!
    @banner = Banner.find(value)
  end

  def persisted?
    !bd.changed? && stubborn_redis_hgetall('banners')[@banner.identifier].present?
  end

  def save
    res = stubborn_redis_hmset 'banners', @banner.identifier => :hidden
    changes_applied
    res == 'OK'
  end

  def stubborn_identifier
    user && user.id
  end

  def stubborn_params
    ['banners', @banner.identifier => :hidden]
  end

  def user=(value)
    user_will_change!
    @user = value
  end
end
