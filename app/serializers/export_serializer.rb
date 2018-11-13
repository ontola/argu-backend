# frozen_string_literal: true

class ExportSerializer < RecordSerializer
  attribute :download_url, predicate: NS::SCHEMA[:url]
  attribute :status, predicate: NS::ARGU[:exportStatus]
  has_one :user, predicate: NS::SCHEMA[:creator]
  has_one :edge, predicate: NS::SCHEMA[:object]
  has_one :export_collection

  def download_url
    object.zip.url
  end

  def export_collection
    object.edge.export_collection
  end
end
