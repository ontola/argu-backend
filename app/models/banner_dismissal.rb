# frozen_string_literal: true
class BannerDismissal
  include ActiveModel::Dirty, ActiveModel::Model, ActiveModel::Validations
  include StubbornCookie

  attr_accessor :banner, :user, :banner_class, :banner_key
  define_attribute_methods :banner, :user

  validates :banner, :user, presence: true

  def initialize(options = {})
    @banner_class = options[:banner_class] || Banner
    @user = options[:user]
    self.banner_id = options[:banner_id] if options[:banner_id].present?
    self.banner = options[:banner] if options[:banner].present?
    @banner_key = @banner_class.model_name.collection
  end

  def banner=(value)
    banner_will_change!
    @banner = value
  end

  def banner_id=(value)
    banner_will_change!
    @banner = @banner_class.find(value)
  end

  def persisted?
    !bd.changed? && stubborn_redis_hgetall(@banner_key)[@banner.identifier].present?
  end

  def save
    res = stubborn_redis_hmset @banner_key, @banner.identifier => :hidden
    changes_applied
    res == 'OK'
  end

  def stubborn_identifier
    user.id
  end

  def stubborn_params
    [@banner_key, @banner.identifier => :hidden]
  end

  def user=(value)
    user_will_change!
    @user = value
  end
end
