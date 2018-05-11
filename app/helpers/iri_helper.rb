# frozen_string_literal: true

module IRIHelper
  include RedirectHelper
  include UUIDHelper

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
    return {} unless argu_iri_or_relative?(iri)
    parent = Rails.application.routes.recognize_path(iri)
    return {} unless parent[:id].present? && parent[:controller].present?
    {id: parent[:id], type: parent[:controller].singularize}
  rescue ActionController::RoutingError
    {}
  end

  # Converts an Argu URI into a resource
  # @return [ApplicationRecord, nil] The resource corresponding to the iri, or nil if the IRI is not found
  def resource_from_iri(iri)
    opts = id_and_type_from_iri(iri)
    return if opts[:type].blank? || opts[:id].blank?
    opts[:class] = ApplicationRecord.descendants.detect { |m| m.to_s == opts[:type].classify }
    resource_from_opts(opts)
  end

  def resource_from_opts(opts)
    return if opts[:class].blank? || opts[:id].blank?
    if opts[:class].try(:shortnameable?)
      opts[:class]&.find_via_shortname_or_id(opts[:id])
    elsif opts[:class] == Edge && uuid?(opts[:id])
      Edge.find_by(uuid: opts[:id])
    else
      opts[:class]&.find_by(id: opts[:id])
    end
  end

  def resource_from_iri!(iri)
    resource_from_iri(iri) || raise(ActiveRecord::RecordNotFound)
  end
end
