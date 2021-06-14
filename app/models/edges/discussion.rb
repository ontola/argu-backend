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
  enhance Timelineable

  parentable :container_node, :page
  filterable(
    NS::ARGU[:pinned] => boolean_filter(
      ->(scope) { scope.where.not(pinned_at: nil) },
      ->(scope) { scope.where(pinned_at: nil) }
    ),
    NS::ARGU[:trashed] => boolean_filter(
      ->(scope) { scope.where.not(trashed_at: nil) },
      ->(scope) { scope.where(trashed_at: nil) }
    )
  )
  paginates_per 12
  placeable :custom

  class << self
    def inherited(klass)
      klass.send(:counter_cache, true)
      super
    end
  end
end
