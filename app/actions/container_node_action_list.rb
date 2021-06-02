# frozen_string_literal: true

class ContainerNodeActionList < ApplicationActionList
  ContainerNode.descendants.each do |klass|
    has_action(
      "new_#{klass.name.underscore}",
      collection: true,
      exclude: true,
      predicate: NS::ONTOLA[:createAction],
      root_relative_iri: -> { new_iri_path(klass.root_collection.root_relative_iri) }
    )
  end
end
