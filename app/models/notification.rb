# frozen_string_literal: true

class Notification < ApplicationRecord
  enhance LinkedRails::Enhancements::Updatable

  include ActivityHelper
  include ActionView::Helpers
  include Cacheable

  belongs_to :user
  belongs_to :activity
  before_create :set_notification_type

  validates :title, length: {maximum: 140}
  validates :url, length: {maximum: 512}

  scope :for_activity, -> { where.not(activity_id: nil) }
  collection_options(
    type: :infinite
  )

  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid
  enum notification_type: {
    link: 0, _decision: 1, news: 2, reaction: 3, confirmation_reminder: 4,
    finish_intro: 5, drafts_reminder: 6
  }
  virtual_attribute :unread, :boolean, default: false, dependent_on: :read_at, value: ->(r) { r.read_at.blank? }

  def display_name # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    if activity.present?
      activity_string_for(activity, user)
    elsif confirmation_reminder?
      vote_count = user.edges.joins(:parent).where(owner_type: 'Vote', parents_edges: {owner_type: 'VoteEvent'}).count
      I18n.t('notifications.permanent.confirm_account', count: vote_count, email: user.email)
    elsif drafts_reminder?
      drafts_count = user.drafts.count
      I18n.t('notifications.permanent.drafts_reminder', count: drafts_count)
    else
      title
    end
  end

  def url_object
    return activity.trackable.iri if activity.present?
    return if url.blank?
    return LinkedRails.iri(path: url) if url.start_with?('/')

    RDF::URI(url)
  end

  def mailer_options # rubocop:disable Metrics/MethodLength
    case notification_type&.to_sym
    when :confirmation_reminder
      {
        token_url: iri_from_template(
          :user_confirmation,
          confirmation_token: user.primary_email_record.confirmation_token
        )
      }
    when :drafts_reminder
      {drafts_url: iri_from_template(:user_sign_in, redirect_url: drafts_iri.to_s)}
    else
      {}
    end
  end

  def set_notification_type
    return if activity.nil?

    self.notification_type = activity.follow_type.singularize.to_sym
  end

  class << self
    def attributes_for_new(opts)
      user_context = opts[:user_context]
      {user: user_context&.user || User.new(show_feed: true)}
    end

    def route_key
      :n
    end
  end
end
