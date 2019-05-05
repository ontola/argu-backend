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

  include HasLinks

  counter_cache true
  parentable :container_node, :page
  filterable pinned: {key: :pinned_at, values: {yes: 'NOT NULL', no: 'NULL'}}
  paginates_per 12
end
