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
      ->(scope) { scope.where(pinned_at: nil) }
    ),
    NS.argu[:trashed] => boolean_filter(
      ->(scope) { scope.where.not(trashed_at: nil) },
      ->(scope) { scope.where(trashed_at: nil) }
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
    def inherited(klass)
      klass.send(:counter_cache, true)
      super
    end
  end
end
