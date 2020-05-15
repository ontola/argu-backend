# frozen_string_literal: true

class ExportSerializer < RecordSerializer
  attribute :download_url, predicate: NS::SCHEMA[:url] do |object|
    object.zip.url
  end
  attribute :status, predicate: NS::ARGU[:exportStatus]
  has_one :user, predicate: NS::SCHEMA[:creator]
  has_one :edge, predicate: NS::SCHEMA[:object]
  has_one :export_collection do |object|
    object.edge.export_collection
  end
end
