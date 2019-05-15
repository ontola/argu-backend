# frozen_string_literal: true

class Discussion < Edge
  attr_accessor :forum, :page, :publisher
  parentable :container_node, :page
  filterable pinned: {key: :pinned_at, values: {yes: 'NOT NULL', no: 'NULL'}}
  paginates_per 12

  def parent
    forum || page
  end
  alias edgeable_record parent

  class << self
    def includes_for_serializer
      Motion.includes_for_serializer.merge(Question.includes_for_serializer)
    end

    def preview_includes
      Motion.preview_includes + Question.preview_includes
    end

    def show_includes
      Motion.show_includes + Question.show_includes
    end
  end
end
