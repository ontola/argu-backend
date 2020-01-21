# frozen_string_literal: true

class DiscussionActionList < ApplicationActionList
  Discussion.descendants.each do |klass|
    has_action(
      "new_#{klass.name.underscore}",
      collection: true,
      exclude: true,
      predicate: NS::ONTOLA[:createAction],
      root_relative_iri: lambda {
        collection_path = resource.parent.try("#{klass.to_s.underscore}_collection")&.iri_path
        collection_path ? new_iri_path(collection_path) : '/'
      }
    )
  end
end
