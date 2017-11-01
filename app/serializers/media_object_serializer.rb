# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  attribute :url, predicate: RDF::SCHEMA[:url]
  attribute :thumbnail, predicate: RDF::SCHEMA[:thumbnail]
  attribute :used_as

  def type
    object.is_image? ? RDF::SCHEMA[:ImageObject] : RDF::SCHEMA[:MediaObject]
  end
end
