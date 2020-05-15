# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  include Parentable::Serializer

  attribute :type, predicate: RDF[:type] do |object|
    if object.type == 'image' || object.profile_photo? || object.cover_photo?
      NS::SCHEMA[:ImageObject]
    elsif object.type == 'video'
      NS::SCHEMA[:VideoObject]
    else
      NS::SCHEMA[:MediaObject]
    end
  end
  attribute :content, predicate: NS::SCHEMA[:contentUrl] do |object|
    object.url_for_version('content')
  end
  attribute :content_type,
            predicate: NS::SCHEMA[:encodingFormat],
            datatype: NS::XSD[:string] do |object|
    object.content_type unless object.type == 'video'
  end
  attribute :created_at, predicate: NS::SCHEMA[:uploadDate]
  attribute :description, predicate: NS::SCHEMA[:caption]
  attribute :embed_url, predicate: NS::SCHEMA[:embedUrl]
  attribute :filename, predicate: NS::DBO[:filename]
  attribute :remote_content_url,
            predicate: NS::ARGU[:remoteContentUrl],
            datatype: NS::XSD[:string], &:remote_url
  attribute :thumbnail, predicate: NS::SCHEMA[:thumbnail] do |object|
    object.url_for_version('thumbnail')
  end
  attribute :position_y,
            predicate: NS::ONTOLA[:imagePositionY],
            datatype: NS::XSD[:integer] do |object|
    object.position_y || 50
  end
  attribute :used_as

  MediaObjectUploader::IMAGE_VERSIONS.each do |format, opts|
    attribute format, predicate: NS::ONTOLA[:"imgUrl#{opts[:w]}x#{opts[:h]}"] do |object|
      object.url_for_version(format)
    end
  end
end
