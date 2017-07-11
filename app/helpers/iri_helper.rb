# frozen_string_literal: true
module IRIHelper
  ARGU_URI_MATCH = /(#{Regexp.quote(Rails.configuration.host_name)}|argu.co)/

  # Converts an Argu URI into a hash containing the type and id of the resource
  # @return [Hash] The id and type of the resource, or nil if the IRI is not found
  # @example Valid IRI
  #   iri = 'https://argu.co/m/1'
  #   id_and_type_from_iri # => {type: 'motions', id: '1'}
  # @example Invalid IRI
  #   iri = 'https://example.com/m/1'
  #   id_and_type_from_iri # => {}
  # @example Nil IRI
  #   iri = nil
  #   id_and_type_from_iri # => {}
  def id_and_type_from_iri(iri)
    match = iri =~ ARGU_URI_MATCH unless iri.nil?
    return {} if iri.nil? || (match.nil? || match <= 0) && URI.parse(iri).hostname.present?
    parent = Rails.application.routes.recognize_path(iri)
    return {} unless parent[:action] == 'show' && parent[:id].present? && parent[:controller].present?
    {id: parent[:id], type: parent[:controller].singularize}
  rescue ActionController::RoutingError
    {}
  end

  # Converts an Argu URI into a resource
  # @return [ApplicationRecord, nil] The resource corresponding to the iri, or nil if the IRI is not found
  def resource_from_iri(iri)
    id, type = id_and_type_from_iri(iri).values
    klass = ApplicationRecord.descendants.detect { |m| m.to_s == type.classify } if id.present? || type.present?
    return if klass.nil?
    klass.shortnameable? ? klass.find_via_shortname!(id) : klass.find(id)
  end
end
