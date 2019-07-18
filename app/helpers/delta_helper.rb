# frozen_string_literal: true

module DeltaHelper
  include LinkedRails::Helpers::DeltaHelper

  def action_delta(data, delta, object, action, opts = {})
    [NS::SCHEMA[:potentialAction], opts[:include_favorite] ? NS::ONTOLA[:favoriteAction] : nil].compact.each do |pred|
      [object, opts[:include_parent] ? object.parent : nil].compact.each do |obj|
        data << [
          obj.iri,
          pred,
          ::RDF::DynamicURI("#{object.iri}/actions/#{action}"),
          delta_iri(delta)
        ]
      end
    end
  end

  def counter_cache_delta(resource)
    return [] if resource.try(:counter_cache_options).blank?

    if resource.is_a?(Vote) && resource.parent.is_a?(Argument)
      [counter_column_delta(resource, :votes_pro)]
    else
      [counter_column_delta(resource, resource.class_name)]
    end
  end

  def counter_column_delta(resource, column)
    [
      resource.parent.iri,
      NS::ARGU["#{column.to_s.camelcase(:lower)}Count".to_sym],
      resource.parent.reload.children_count(column),
      delta_iri(:replace)
    ]
  end

  def n3_delta(array)
    repo = RDF::Repository.new
    array.each { |nquad| repo << nquad }
    repo.dump(:nquads)
  end

  def resource_added_delta(resource)
    delta = super + counter_cache_delta(resource)
    delta << invalidate_resource_delta(resource.action(:publish)) if resource.try(:is_publishable?)
    delta
  end

  def resource_removed_delta(resource)
    super + counter_cache_delta(resource)
  end
end
