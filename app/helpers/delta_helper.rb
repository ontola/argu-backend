# frozen_string_literal: true

module DeltaHelper
  include LinkedRails::Helpers::DeltaHelper
  include RDF::Serializers::HextupleSerializer

  def counter_cache_delta(resource)
    return [] if resource.try(:counter_cache_options).blank?

    if resource.is_a?(Vote)
      resource.parent.vote_counts(delta_iri(:replace))
    else
      [counter_column_delta(resource, resource.class_name)]
    end
  end

  def counter_column_delta(resource, column)
    [
      resource.parent.iri,
      NS.argu["#{column.to_s.camelcase(:lower)}Count".to_sym],
      resource.parent.reload.children_count(column),
      delta_iri(:replace)
    ]
  end

  def hex_delta(array)
    array.map { |s| Oj.fast_generate(value_to_hex(*s)) }.join("\n")
  end

  def resource_added_delta(resource)
    delta = super + counter_cache_delta(resource)
    delta << invalidate_resource_delta(resource.action(:publish)) if resource.try(:is_publishable?)
    delta.concat(resource.added_delta) if resource.respond_to?(:added_delta)
    delta
  end

  def resource_removed_delta(resource)
    delta = super + counter_cache_delta(resource)
    delta.concat(resource.removed_delta) if resource.respond_to?(:removed_delta)
    delta
  end
end
