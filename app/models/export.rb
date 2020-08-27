# frozen_string_literal: true

class Export < ApplicationRecord
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Indexable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Tableable
  include Parentable

  belongs_to :user
  belongs_to :edge, primary_key: :uuid
  after_commit :schedule_export_job, on: :create
  enum status: {pending: 0, processing: 1, done: 2, failed: -1}
  mount_uploader :zip, ExportUploader
  parentable :edge
  with_columns default: [
    NS::SCHEMA[:dateCreated],
    NS::SCHEMA[:url],
    NS::ARGU[:exportStatus],
    NS::ONTOLA[:destroyAction]
  ]

  def display_name
    "Export #{created_at}"
  end

  def edgeable_record
    @edgeable_record ||= edge
  end

  private

  def schedule_export_job
    ExportWorker.perform_async(id)
  end
end
