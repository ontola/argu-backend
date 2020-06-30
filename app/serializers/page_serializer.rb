# frozen_string_literal: true

class PageSerializer < EdgeSerializer
  def self.manager?(object, opts)
    opts[:scope].user.managed_pages.include?(object)
  end

  attribute :name, predicate: NS::FOAF[:name], datatype: NS::XSD[:string] do |object|
    profile = object.is_a?(Profile) ? object : object.profile
    profile&.name
  end
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]
  attribute :accepted_terms, predicate: NS::ARGU[:acceptedTerms], datatype: NS::XSD[:boolean], if: method(:manager?)
  attribute :last_accepted, predicate: NS::ARGU[:lastAccepted], if: method(:manager?)
  attribute :database_schema, predicate: NS::ARGU[:dbSchema], if: method(:service_scope?)
  attribute :styled_headers, predicate: NS::ONTOLA[:styledHeaders]
  attribute :requires_intro, predicate: NS::ONTOLA[:requiresIntro]

  belongs_to :primary_container_node, predicate: NS::FOAF[:homepage], unless: method(:service_scope?)
  has_one :profile, predicate: NS::ARGU[:profile]

  with_collection :container_nodes, predicate: NS::ARGU[:forums]
end
