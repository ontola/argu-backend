class Publication < ActiveRecord::Base
  include Wisper::Publisher
  belongs_to :publishable, polymorphic: true
  belongs_to :creator, class_name: 'Profile', inverse_of: :projects
  belongs_to :publisher, class_name: 'User'

  after_save :re_schedule_or_destroy
  before_destroy :cancel_job
  after_rollback :cancel_job

  def commit
    publishable.update(is_published: true)
    publish("publish_#{publishable.model_name.singular}_successful", publishable)
  end

  private

  # Cancel the scheduled PublishJob
  def cancel_job
    PublicationsWorker.cancel!(job_id) if job_id.present?
  end

  # Cancel a previously scheduled job and either schedule a new job, or destroy the publication
  def re_schedule_or_destroy
    cancel_job if job_id.present? && published_at_changed?
    return if publishable.is_published?
    published_at.present? ? schedule : destroy
  end

  # Create a PublicationsWorker and save it's job id
  def schedule
    self.job_id = PublicationsWorker.perform_at(published_at,
                                                publishable.id,
                                                publishable.model_name.name)
  end
end
