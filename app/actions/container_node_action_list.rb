# frozen_string_literal: true

class ContainerNodeActionList < ApplicationActionList
  # still relevant? @todo
  ContainerNode.descendants.each do |klass|
    has_collection_action(
      "new_#{klass.name.underscore}",
      create_collection_options(
        predicate: NS::ONTOLA[:createAction],
        root_relative_iri: -> { new_iri_path(klass.root_collection.root_relative_iri) }
      )
    )
  end
end
