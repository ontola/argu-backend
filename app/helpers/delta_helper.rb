# frozen_string_literal: true

module DeltaHelper
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

  def add_resource_delta(resource)
    invalidate_parent_collections_delta(resource) + counter_cache_delta(resource) + [
      invalidate_resource_delta(resource),
      resource.try(:is_publishable?) ? invalidate_resource_delta(resource.action(:publish)) : nil
    ].compact
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

  def delta_iri(delta)
    %i[remove replace invalidate].include?(delta) ? NS::ONTOLA[delta] : NS::LL[delta]
  end

  def invalidate_collection_delta(collection)
    [LinkedRails::NS::SP[:Variable], NS::ONTOLA[:baseCollection], collection.iri, NS::ONTOLA[:invalidate]]
  end

  def invalidate_parent_collections_delta(resource)
    resource.parent_collections.map(&method(:invalidate_collection_delta))
  end

  def invalidate_resource_delta(resource)
    [resource.iri, LinkedRails::NS::SP[:Variable], LinkedRails::NS::SP[:Variable], NS::ONTOLA[:invalidate]]
  end

  def n3_delta(array)
    repo = RDF::Repository.new
    array.each { |nquad| repo << nquad }
    repo.dump(:nquads)
  end

  def remove_resource_delta(resource)
    invalidate_parent_collections_delta(resource) + counter_cache_delta(resource)
  end
end
