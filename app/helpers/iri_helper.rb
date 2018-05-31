# frozen_string_literal: true

module IRIHelper
  include RedirectHelper
  include UUIDHelper

  def edge_from_opts(opts)
    if uuid?(opts[:id])
      Edge.find_by(uuid: opts[:id])
    else
      Edge.find_by(fragment: opts[:id], root_id: root_id_from_opts(opts))
    end
  end

  def edge_from_opts?(opts)
    opts[:class] <= Edge
  end

  def decision_from_opts(opts)
    return unless opts[:class] == Decision
    Decision
      .joins(:parent)
      .where('parents_edges.root_id = edges.root_id')
      .where(parents_edges: {fragment: opts[parent_resource_key(opts)]}, root_id: root_id_from_opts(opts))
      .find_by(step: opts[:id])
  end

  def decision_from_opts?(opts)
    opts[:class] == Decision
  end

  def linked_record_from_opts(opts)
    LinkedRecord.find_by(deku_id: opts[:id])
  end

  def linked_record_from_opts?(opts)
    opts[:class] == LinkedRecord && uuid?(opts[:id])
  end

  # Converts an Argu URI into a hash containing the type and id of the resource
  # @return [Hash] The id and type of the resource, or nil if the IRI is not found
  # @example Valid IRI
  #   iri = 'https://argu.co/m/1'
  #   opts_from_iri # => {type: 'motions', id: '1'}
  # @example Invalid IRI
  #   iri = 'https://example.com/m/1'
  #   opts_from_iri # => {}
  # @example Nil IRI
  #   iri = nil
  #   opts_from_iri # => {}
  def opts_from_iri(iri)
    return {} unless argu_iri_or_relative?(iri)
    opts = Rails.application.routes.recognize_path(iri)
    return {} unless opts[:id].present? && opts[:controller].present?
    opts[:type] = opts[:controller].singularize
    opts
  rescue ActionController::RoutingError
    {}
  end

  # Finds a 'resource key' from a params Hash
  # @example Resource key from motion_id
  #   params = {motion_id: 1}
  #   parent_resource_key # => :motion_id
  def parent_resource_key(hash)
    hash
      .keys
      .reject { |k| k.to_s == 'root_id' }
      .reverse
      .find { |k| /_id/ =~ k }
  end

  # Converts an Argu URI into a resource
  # @return [ApplicationRecord, nil] The resource corresponding to the iri, or nil if the IRI is not found
  def resource_from_iri(iri)
    opts = opts_from_iri(iri)
    return if opts[:type].blank? || opts[:id].blank?
    opts[:class] = ApplicationRecord.descendants.detect { |m| m.to_s == opts[:type].classify }
    resource_from_opts(opts)
  end

  def resource_from_opts(opts)
    return if opts[:class].blank? || opts[:id].blank?
    return shortnameable_from_opts(opts) if shortnameable_from_opts?(opts)
    return linked_record_from_opts(opts) if linked_record_from_opts?(opts)
    return decision_from_opts(opts) if decision_from_opts?(opts)
    return edge_from_opts(opts) if edge_from_opts?(opts)
    opts[:class]&.find_by(id: opts[:id])
  end

  def resource_from_iri!(iri)
    resource_from_iri(iri) || raise(ActiveRecord::RecordNotFound)
  end

  def root_id_from_opts(opts)
    return opts[:root_id] if uuid?(opts[:root_id])
    Page.find_via_shortname_or_id(opts[:root_id])&.uuid
  end

  def shortnameable_from_opts(opts)
    if root_id_from_opts(opts).present?
      opts[:class]&.find_via_shortname_or_id(opts[:id], root_id_from_opts(opts))
    else
      opts[:class]&.find_via_shortname_or_id(opts[:id])
    end
  end

  def shortnameable_from_opts?(opts)
    opts[:class].try(:shortnameable?) && (/[a-zA-Z]/i =~ opts[:id]).present?
  end
end
