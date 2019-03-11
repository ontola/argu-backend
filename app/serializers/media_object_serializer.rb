# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  include Parentable::Serializer

  attribute :url, predicate: NS::SCHEMA[:url]
  attribute :content, predicate: NS::SCHEMA[:contentUrl]
  attribute :content_type, predicate: NS::SCHEMA[:encodingFormat]
  attribute :created_at, predicate: NS::SCHEMA[:uploadDate]
  attribute :description, predicate: NS::SCHEMA[:caption]
  attribute :embed_url, predicate: NS::SCHEMA[:embedUrl]
  attribute :filename, predicate: NS::DBO[:filename]
  attribute :thumbnail, predicate: NS::SCHEMA[:thumbnail]
  attribute :position_y,
            predicate: NS::ARGU[:imagePositionY],
            datatype: NS::XSD[:integer]
  attribute :used_as

  MediaObjectUploader::VERSIONS.each do |format, opts|
    attribute format, predicate: NS::ARGU[:"imgUrl#{opts[:w]}x#{opts[:h]}"]

    define_method format do
      url = object.content.url(format)
      url && RDF::DynamicURI(url)
    end
  end

  def content_type
    object.content_type unless object.type == 'video'
  end

  def type
    if object.type == 'image' || object.profile_photo? || object.cover_photo?
      NS::SCHEMA[:ImageObject]
    elsif object.type == 'video'
      NS::SCHEMA[:VideoObject]
    else
      NS::SCHEMA[:MediaObject]
    end
  end
end
