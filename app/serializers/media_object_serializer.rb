# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  extend LinkedRails::Helpers::OntolaActionsHelper
  extend UriTemplateHelper
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
    object.url_for_version('content') if object.persisted?
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
  attribute :used_as, predicate: NS::ARGU[:fileUsage]
  attribute :copy_url, predicate: NS::ARGU[:copyUrl] do |object|
    ontola_copy_action(object.iri)
  end
  enum :content_source, predicate: NS::ARGU[:contentSource]
  statements :copy_action_statements

  MediaObjectUploader::IMAGE_VERSIONS.each do |format, opts|
    attribute format, predicate: NS::ONTOLA[:"imgUrl#{opts[:w]}x#{opts[:h]}"] do |object|
      object.url_for_version(format)
    end
  end

  class << self
    def copy_action_statements(object, _params) # rubocop:disable Metrics/AbcSize
      action_iri = ontola_copy_action(object.iri)
      target_iri = RDF::URI("#{action_iri}#entrypoint")
      [
        RDF::Statement.new(action_iri, RDF[:type], NS::ARGU[:CopyAction]),
        RDF::Statement.new(action_iri, NS::SCHEMA.name, I18n.t('menus.default.copy')),
        RDF::Statement.new(action_iri, NS::SCHEMA.target, target_iri),
        RDF::Statement.new(target_iri, RDF[:type], NS::SCHEMA.EntryPoint),
        RDF::Statement.new(target_iri, NS::SCHEMA.name, I18n.t('menus.default.copy')),
        RDF::Statement.new(target_iri, NS::SCHEMA.image, font_awesome_iri('clipboard'))
      ]
    end
  end
end
