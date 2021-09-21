# frozen_string_literal: true

class Export < ApplicationRecord
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  include Parentable

  belongs_to :user
  belongs_to :edge, primary_key: :uuid
  after_commit :schedule_export_job, on: :create
  enum status: {pending: 0, processing: 1, done: 2, failed: -1}
  mount_uploader :zip, ExportUploader
  parentable :edge
  with_columns default: [
    NS.schema.dateCreated,
    NS.schema.downloadUrl,
    NS.argu[:exportStatus],
    NS.ontola[:destroyAction]
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

  class << self
    def attributes_for_new(opts)
      {
        edge: opts[:parent],
        user: opts[:user_context]&.user
      }
    end

    def default_collection_display
      :table
    end
  end
end
