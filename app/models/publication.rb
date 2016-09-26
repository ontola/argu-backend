# frozen_string_literal: true
class Publication < ApplicationRecord
  include Wisper::Publisher
  belongs_to :publishable, class_name: 'Edge'
  belongs_to :creator, class_name: 'Profile', inverse_of: :projects
  belongs_to :publisher, class_name: 'User'

  before_save :reset
  before_destroy :cancel
  after_rollback :cancel

  attr_accessor :publish_type
  enum publish_type: {direct: 0, draft: 1, schedule: 2}

  # @TODO: wrap in transaction
  def commit
    return if publishable.owner.is_published?
    publishable.owner.update(is_published: true)
    publishable.owner.happening.update(is_published: true) if publishable.owner.respond_to?(:happening)
    publish("publish_#{publishable.owner.model_name.singular}_successful", publishable.owner)
  end

  private

  # Cancel the scheduled PublishJob
  def cancel
    PublicationsWorker.cancel!(job_id) if job_id.present?
  end

  # Cancel a previously scheduled job and schedule a new job if needed
  def reset
    return if publishable.owner.is_published?

    cancel if job_id.present?
    schedule if published_at.present?
  end

  # Create a PublicationsWorker and save it's job id
  def schedule
    self.job_id = PublicationsWorker.perform_at(published_at,
                                                publishable.id,
                                                publishable.model_name.name)
  end
end
