# frozen_string_literal: true

class Export < ApplicationRecord
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  include Cacheable
  include Parentable

  belongs_to :user
  belongs_to :edge, primary_key: :uuid
  after_commit :schedule_export_job, on: :create
  after_update :notify_status_change

  enum status: {pending: 0, processing: 1, done: 2, failed: -1}

  mount_uploader :zip, ExportUploader
  parentable :edge
  collection_options(
    display: :table
  )
  with_columns default: [
    NS.schema.dateCreated,
    NS.schema.downloadUrl,
    NS.argu[:exportStatus],
    NS.ontola[:destroyAction]
  ]

  def display_name
    "Export #{created_at}"
  end

  def download_url
    zip.url
  end

  def edgeable_record
    @edgeable_record ||= edge
  end

  private

  def notify_status_change
    return unless status_previously_changed?

    SendEmailWorker.perform_async(:export_done, user_id, download_url: download_url) if done?
    SendEmailWorker.perform_async(:export_failed, user_id) if failed?
  end

  def schedule_export_job
    ExportWorker.perform_async(id)
  end

  class << self
    def attributes_for_new(opts)
      {
        edge: opts[:parent] || ActsAsTenant.current_tenant,
        user: opts[:user_context]&.user
      }
    end
  end
end
