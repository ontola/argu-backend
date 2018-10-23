# frozen_string_literal: true

class Publication < ApplicationRecord
  include Ldable
  include Wisper::Publisher
  belongs_to :publishable, class_name: 'Edge', primary_key: :uuid
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  after_commit :reset
  before_destroy :cancel
  after_rollback :cancel

  validates :creator, :publisher, :channel, presence: true

  attribute :draft, :boolean, default: false
  enum follow_type: {news: 2, reactions: 3}

  alias edgeable_record publishable

  # @TODO: wrap in transaction
  def commit
    return if publishable.is_published?
    publishable.publish!
    return unless publishable.is_published
    publish("publish_#{publishable.model_name.singular}_successful", publishable)
  end

  def publish_time_lapsed?
    published_at.present? && published_at <= 10.seconds.from_now
  end

  def publish_type
    @publish_type ||=
      if published_at.nil?
        'draft'
      elsif published_at <= 10.seconds.from_now
        'direct'
      else
        'schedule'
      end
  end

  private

  # Cancel the scheduled PublishJob
  def cancel
    PublicationsWorker.cancel!(job_id) if job_id.present?
  end

  # Cancel a previously scheduled job and schedule a new job if needed
  def reset
    return if destroyed? || publishable.is_published?

    cancel if job_id.present?
    schedule if published_at.present?
  end

  # Create a PublicationsWorker and save it's job id
  def schedule
    self.job_id = PublicationsWorker.perform_at(published_at, publishable.uuid)
  end
end
