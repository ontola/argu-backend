# frozen_string_literal: true

class Export < ApplicationRecord
  enhance Createable
  enhance Destroyable
  enhance Actionable
  include Parentable

  belongs_to :user
  belongs_to :edge, primary_key: :uuid
  after_commit :schedule_export_job, on: :create
  enum status: {pending: 0, processing: 1, done: 2, failed: -1}
  mount_uploader :zip, ExportUploader
  parentable :edge

  def display_name
    "Export #{created_at}"
  end

  def edgeable_record
    @edgeable_record ||= edge
  end

  def iri_opts
    super.merge(root_id: parent.root.url)
  end

  private

  def schedule_export_job
    ExportWorker.perform_async(id)
  end
end
