# frozen_string_literal: true

class PageSerializer < EdgeSerializer
  extend LanguageHelper

  attribute :name, predicate: NS.foaf[:name], datatype: NS.xsd.string do |object|
    profile = object.is_a?(Profile) ? object : object.profile
    profile&.name
  end
  attribute :url, predicate: NS.argu[:shortname], datatype: NS.xsd.string
  attribute :full_iri, predicate: NS.schema.url do |object|
    URI("https://#{object.iri_prefix}")
  end
  attribute :follows_count, predicate: NS.argu[:followsCount]

  has_one :primary_container_node, predicate: NS.foaf[:homepage], unless: method(:service_scope?)
  has_one :profile, predicate: NS.argu[:profile]

  with_collection :container_nodes, predicate: NS.argu[:forums]

  enum :tier,
       predicate: NS.argu[:tier]
  enum :language,
       type: NS.schema.Language,
       predicate: NS.schema.language,
       options: available_locales
end
