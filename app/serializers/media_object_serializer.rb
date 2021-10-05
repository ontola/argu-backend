# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  extend LinkedRails::Helpers::OntolaActionsHelper
  extend UriTemplateHelper
  include Parentable::Serializer

  attribute :type, predicate: RDF[:type] do |object|
    if object.type == 'image' || object.profile_photo? || object.cover_photo?
      NS.schema.ImageObject
    elsif object.type == 'video'
      NS.schema.VideoObject
    else
      NS.schema.MediaObject
    end
  end
  attribute :content, predicate: NS.schema.contentUrl do |object|
    object.url_for_version('content') if object.persisted?
  end
  attribute :content_type,
            predicate: NS.schema.encodingFormat,
            datatype: NS.xsd.string do |object|
    object.content_type unless object.type == 'video'
  end
  attribute :created_at, predicate: NS.schema.uploadDate
  attribute :description, predicate: NS.schema.caption
  attribute :embed_url, predicate: NS.schema.embedUrl
  attribute :filename, predicate: NS.dbo[:filename] do |object|
    object.filename || object.content_uid
  end
  attribute :remote_content_url,
            predicate: NS.argu[:remoteContentUrl],
            datatype: NS.xsd.string, &:remote_url
  attribute :thumbnail, predicate: NS.schema.thumbnail do |object|
    object.url_for_version('thumbnail')
  end
  attribute :position_y,
            predicate: NS.ontola[:imagePositionY],
            datatype: NS.xsd.integer do |object|
    object.position_y || 50
  end
  attribute :used_as, predicate: NS.argu[:fileUsage]
  attribute :copy_url, predicate: NS.argu[:copyUrl] do |object|
    ontola_copy_action(object.iri)
  end
  enum :content_source, predicate: NS.argu[:contentSource]
  statements :copy_action_statements

  MediaObjectUploader::IMAGE_VERSIONS.each do |format, opts|
    attribute format, predicate: NS.ontola[:"imgUrl#{opts[:w]}x#{opts[:h]}"] do |object|
      object.url_for_version(format)
    end
  end

  class << self
    def copy_action_statements(object, _params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      action_iri = ontola_copy_action(object.iri)
      target_iri = RDF::URI("#{action_iri}#entrypoint")
      [
        RDF::Statement.new(action_iri, RDF[:type], NS.schema.Action),
        RDF::Statement.new(action_iri, NS.schema.name, I18n.t('menus.default.copy')),
        RDF::Statement.new(action_iri, NS.schema.target, target_iri),
        RDF::Statement.new(action_iri, NS.ontola[:oneClick], true),
        RDF::Statement.new(target_iri, RDF[:type], NS.schema.EntryPoint),
        RDF::Statement.new(target_iri, NS.schema.name, I18n.t('menus.default.copy')),
        RDF::Statement.new(target_iri, NS.schema.image, font_awesome_iri('clipboard'))
      ]
    end
  end
end
