# frozen_string_literal: true

class Discussion < Edge
  self.abstract_class = true

  enhance Attachable
  enhance BlogPostable
  enhance Commentable
  enhance Contactable
  enhance Convertible
  enhance CoverPhotoable
  enhance Exportable
  enhance Feedable
  enhance Inviteable
  enhance MarkAsImportant
  enhance Moveable
  enhance Placeable
  enhance Statable

  parentable :container_node, :page
  filterable(
    NS.argu[:pinned] => boolean_filter(
      ->(scope) { scope.where.not(pinned_at: nil) },
      ->(scope) { scope.where(pinned_at: nil) },
      visible: lambda {
        !collection.parent.is_a?(Edge) ||
          collection.user_context.has_grant_set?(collection.parent, %i[moderator administrator staff])
      }
    )
  )
  with_columns default: [
    NS.schema.name,
    NS.schema.creator,
    NS.argu[:lastActivityAt],
    NS.argu[:followsCount]
  ]
  paginates_per 12
  placeable :custom

  class << self
    def action_dialog(collection)
      RDF::URI("#{collection.parent.collection_iri(:discussions)}/actions") if self == Discussion
    end

    def action_precedence
      %i[new_thread new_question new_motion new_poll new_swipe_tool new_project new_budget_shop new_survey]
    end

    def inherited(klass)
      klass.send(:counter_cache, true)
      super
    end
  end
end
