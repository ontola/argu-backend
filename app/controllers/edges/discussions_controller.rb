# frozen_string_literal: true

class DiscussionsController < EdgeableController
  Discussion.descendants.each do |klass|
    has_collection_action(
      "new_#{klass.name.underscore}",
      **create_collection_options(
        inherit: false,
        object: lambda {
          resource.parent.build_child(klass, user_context: user_context)
        },
        predicate: NS.ontola[:createAction],
        root_relative_iri: lambda {
          "#{resource.parent.collection_root_relative_iri(klass.name.tableize)}/new"
        }
      )
    )
  end
end
