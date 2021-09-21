# frozen_string_literal: true

class ExportSerializer < RecordSerializer
  attribute :download_url, predicate: NS.schema.downloadUrl do |object|
    object.zip.url
  end
  attribute :status, predicate: NS.argu[:exportStatus]
  has_one :user, predicate: NS.schema.creator
  has_one :edge, predicate: NS.schema.object
  has_one :export_collection do |object|
    object.edge.export_collection
  end
end
