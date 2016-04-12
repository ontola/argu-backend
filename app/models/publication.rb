class Publication < ActiveRecord::Base
  belongs_to :publishable, polymorphic: true

  before_update :reset_published_at, :if => Proc.new {|model| model.published_at_changed? }
  before_destroy :cancel_job

  def execute
    # Increment counter_caches
    publishable.update(is_published: true)
    ActivityListener.new.send("publish_#{publishable.model_name.singular}_successful", publishable)
  end

  # Execute the publication or schedule a job to do so
  def execute_or_schedule
    published_at <= DateTime.current ? execute : schedule
  end

  private

  # Cancel the scheduled PublishJob
  def cancel_job
    PublicationsWorker.cancel!(job_id) if job_id.present?
  end

  # Cancel a previously scheduled job and either schedule a new jFob, execute the publication or destroy the publication
  def reset_published_at
    raise if publishable.is_published?
    cancel_job
    published_at.present? ? execute_or_schedule : destroy
  end

  # Create a PublicationsWorker and save it's job id
  def schedule
    self.job_id = PublicationsWorker.perform_at(published_at, publishable.id, publishable.model_name.name)
  end
end
