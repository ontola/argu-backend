# frozen_string_literal: true

class Notification < ApplicationRecord
  include BlogPostsHelper
  include ActivityHelper
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :activity
  before_create :set_notification_type
  after_destroy :sync_notification_count
  after_update :sync_notification_count

  validates :title, length: {maximum: 140}
  validates :url, length: {maximum: 512}

  scope :renderable, -> { where.not(activity_id: nil) }

  enum notification_type: {link: 0, decision: 1, news: 2, reaction: 3, confirmation_reminder: 4}

  def sync_notification_count
    user.try :sync_notification_count
  end

  def title
    if activity.present?
      activity_string_for(activity, user)
    elsif confirmation_reminder?
      vote_count = RedisResource::Key
                     .new(user: user)
                     .matched_keys
                     .select { |k| k.parent.owner_type == 'VoteEvent' }
                     .count
      t('notifications.permanent.confirm_account', count: vote_count, email: user.email)
    else
      super
    end
  end
  alias display_name title

  def url_object
    if activity.present?
      activity.trackable_type == 'BlogPost' ? url_for_blog_post(activity.trackable) : activity.trackable
    else
      url
    end
  end

  def image
    if activity.present?
      activity.owner.default_profile_photo.url(:avatar)
    else
      ActionController::Base.helpers.asset_path('favicons/favicon-192x192.png')
    end
  end

  def resource
    activity.trackable if activity.present?
  end

  def renderable?
    activity.present?
  end

  def set_notification_type
    return if activity.nil?
    self.notification_type = activity.follow_type.singularize.to_sym
  end

  scope :since, ->(from_time = nil) { where('created_at < :from_time', from_time: from_time) if from_time.present? }
end
