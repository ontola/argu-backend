# frozen_string_literal: true

class Notification < ApplicationRecord
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Updatable

  include ActivityHelper
  include ActionView::Helpers

  belongs_to :user
  belongs_to :activity
  before_create :set_notification_type
  after_destroy :sync_notification_count
  after_update :sync_notification_count

  validates :title, length: {maximum: 140}
  validates :url, length: {maximum: 512}

  scope :for_activity, -> { where.not(activity_id: nil) }

  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid
  enum notification_type: {link: 0, decision: 1, news: 2, reaction: 3, confirmation_reminder: 4, finish_intro: 5}
  virtual_attribute :unread, :boolean, default: false, dependent_on: :read_at, value: ->(r) { r.read_at.blank? }

  def creator_url
    dual_profile_url activity.owner, only_path: false, canonical: true
  end

  def sync_notification_count
    user.try :sync_notification_count
  end

  def display_name # rubocop:disable Metrics/AbcSize
    if activity.present?
      activity_string_for(activity, user)
    elsif confirmation_reminder?
      vote_count = user.edges.joins(:parent).where(owner_type: 'Vote', parents_edges: {owner_type: 'VoteEvent'}).count
      t('notifications.permanent.confirm_account', count: vote_count, email: user.email)
    elsif finish_intro?
      t('notifications.permanent.finish_intro')
    else
      title
    end
  end

  def url_object
    href = activity.present? ? activity.trackable.iri_path : url
    href = path_with_hostname(href) if href.start_with?('/')
    RDF::DynamicURI(href)
  end

  def image
    if activity.present?
      activity.owner.default_profile_photo.url(:avatar)
    else
      ActionController::Base.helpers.asset_path('assets/favicons/default/favicon-192x192.png', skip_pipeline: true)
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

  class << self
    def preview_includes
      [operation: :target]
    end

    def includes_for_serializer
      [:user, activity: {recipient: {}, trackable: :root, owner: :profileable}]
    end
  end
end
