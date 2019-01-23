# frozen_string_literal: true

module IRIHelper
  include RedirectHelper
  include UriTemplateHelper
  include UUIDHelper

  def edge_from_opts(opts)
    if uuid?(opts[:id])
      Edge.find_by(uuid: opts[:id])
    else
      Edge.find_by(fragment: opts[:id])
    end
  end

  def edge_from_opts?(opts)
    opts[:class] <= Edge
  end

  def edge_uuid_from_iri(iri)
    match = uri_template(:edges_iri).match(URI(iri).path).try(:[], 1)
    return match if uuid?(match)
  end

  def decision_from_opts(opts)
    return unless opts[:class] == Decision
    Decision
      .joins(:parent)
      .where('parents_edges.root_id = edges.root_id')
      .where(parents_edges: {fragment: opts[parent_resource_key(opts)]})
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
  def opts_from_iri(iri, root = tree_root)
    opts = Rails.application.routes.recognize_path(DynamicUriHelper.revert(iri, root))
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

  def path_to_url(path)
    return path unless relative_path?(path)
    port = [80, 443].include?(request.port) ? nil : request.port
    URI::Generic.new(request.scheme, nil, request.host, port, nil, path, nil, nil, nil).to_s
  end

  def relative_path?(string)
    string.is_a?(String) && string.starts_with?('/') && !string.starts_with?('//')
  end

  def resource_by_id_from_opts(opts)
    opts[:class]&.find_by(id: opts[:id])
  end

  # Converts an Argu URI into a resource
  # @return [ApplicationRecord, nil] The resource corresponding to the iri, or nil if the IRI is not found
  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def resource_from_iri(iri)
    raise "A full url is expected. #{iri} is given." if iri.blank? || relative_path?(iri)

    edge_uuid = edge_uuid_from_iri(iri)
    return Edge.find_by(uuid: edge_uuid) if edge_uuid

    root = TenantFinder.from_url(iri)
    return if root.blank?

    opts = opts_from_iri(iri, root)
    return root if opts == {}
    return if opts[:type].blank? || opts[:id].blank?

    resource_from_opts(root, opts)
  end

  def resource_from_opts(root, opts)
    opts[:class] ||= ApplicationRecord.descendants.detect { |m| m.to_s == opts[:type].classify } if opts[:type]
    return if opts[:class].blank? || opts[:id].blank?

    ActsAsTenant.with_tenant(root) do
      return shortnameable_from_opts(opts) if shortnameable_from_opts?(opts)
      return linked_record_from_opts(opts) if linked_record_from_opts?(opts)
      return decision_from_opts(opts) if decision_from_opts?(opts)
      return edge_from_opts(opts) if edge_from_opts?(opts)
      resource_by_id_from_opts(opts)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  def resource_from_iri!(iri)
    resource_from_iri(iri) || raise(ActiveRecord::RecordNotFound)
  end

  def shortnameable_from_opts(opts)
    opts[:class]&.find_via_shortname_or_id(opts[:id])
  end

  def shortnameable_from_opts?(opts)
    opts[:class].try(:shortnameable?) && (/[a-zA-Z]/i =~ opts[:id]).present?
  end
end
