# frozen_string_literal: true

class Export < ApplicationRecord
  include Parentable
  include Ldable

  belongs_to :user
  belongs_to :edge
  after_commit :schedule_export_job, on: :create
  enum status: {pending: 0, processing: 1, done: 2, failed: -1}
  mount_uploader :zip, ExportUploader
  parentable :edge

  def display_name
    "Export #{created_at}"
  end

  def iri_opts
    super.merge(root_id: parent_model.root.url)
  end

  private

  def schedule_export_job
    ExportWorker.perform_async(id)
  end
end
