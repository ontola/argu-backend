# frozen_string_literal: true

class LinkedRecord < Edge
  include SerializationHelper

  property :external_iri, :iri, NS.owl.sameAs

  attr_accessor :access_token, :language

  def anonymous_iri?
    false
  end

  def external_statements
    external_body
  end

  def iri_opts
    {iri: external_iri}
  end

  private

  def authorization
    "Bearer #{access_token}" if access_token
  end

  def external_body
    body = external_response.body
    blank_nodes = body.scan(/\["(\w*)"/).flatten.uniq
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
    def requested_single_resource(params, user_context) # rubocop:disable Metrics/MethodLength
      return if params[:iri].blank?

      record =
        LinkedRecord.find_or_initialize_by(
          external_iri: params[:iri],
          parent: ActsAsTenant.current_tenant,
          creator: Profile.community,
          publisher: User.community
        )
      record.access_token = user_context&.doorkeeper_token&.token
      record.language = user_context&.user&.language
      record
    end
  end
end
