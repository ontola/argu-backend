# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  include Parentable::Serializer

  attribute :content, predicate: NS::SCHEMA[:contentUrl]
  attribute :content_type,
            predicate: NS::SCHEMA[:encodingFormat],
            datatype: NS::XSD[:string]
  attribute :created_at, predicate: NS::SCHEMA[:uploadDate]
  attribute :description, predicate: NS::SCHEMA[:caption]
  attribute :embed_url, predicate: NS::SCHEMA[:embedUrl]
  attribute :filename, predicate: NS::DBO[:filename]
  attribute :remote_content_url, predicate: NS::ARGU[:remoteContentUrl], datatype: NS::XSD[:string]
  attribute :thumbnail, predicate: NS::SCHEMA[:thumbnail]
  attribute :position_y,
            predicate: NS::ONTOLA[:imagePositionY],
            datatype: NS::XSD[:integer]
  attribute :used_as

  MediaObjectUploader::VERSIONS.each do |format, opts|
    attribute format, predicate: NS::ONTOLA[:"imgUrl#{opts[:w]}x#{opts[:h]}"]

    define_method format do
      url_for_version(format)
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

  def url
    url_for_version('default')
  end

  def content
    url_for_version('content')
  end

  def position_y
    object.position_y || 50
  end

  def remote_content_url
    object.remote_url
  end

  def thumbnail
    url_for_version('thumbnail')
  end

  private

  def url_for_version(version)
    RDF::DynamicURI(path_with_hostname("#{object.root_relative_iri}/content/#{version}"))
  end
end
