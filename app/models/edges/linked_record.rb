# frozen_string_literal: true

class LinkedRecord < Edge
  enhance Commentable
  include SerializationHelper

  property :external_iri, :iri, NS::OWL.sameAs

  attr_accessor :authorization, :language

  def anonymous_iri?
    false
  end

  def external_statements
    external_body + [
      RDF::Statement.new(
        external_iri,
        RDF::OWL.sameAs,
        iri
      )
    ]
  end

  def iri_opts
    {iri: external_iri}
  end

  def rdf_type; end

  private

  def external_body
    body = external_response.body
    blank_nodes = body.scan(/\[\"(\w*)\"/).flatten.uniq
    replaced_body = blank_nodes.reduce(body) { |result, node| result.gsub(node, "_:#{node}") }
    replaced_body.gsub!('id.openraadsinformatie.nl', 'id.openbesluitvorming.nl')

    RDF::Serializers::HndJSONParser.parse(replaced_body)
  end

  def external_response
    @external_response ||= HTTParty.get(
      external_iri,
      headers: {
        'ACCEPT' => 'application/hex+x-ndjson; charset=utf-8',
        'ACCEPT_LANGUAGE' => language,
        'AUTHORIZATION' => authorization
      }
    )
  end

  class << self
    def find_or_initialize_by_iri(iri, authorization = nil, language = nil)
      record =
        LinkedRecord.find_or_initialize_by(
          external_iri: iri,
          parent: ActsAsTenant.current_tenant,
          creator: Profile.community,
          publisher: User.community
        )
      record.authorization = authorization
      record.language = language
      record
    end
  end
end
