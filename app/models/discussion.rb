# frozen_string_literal: true

class Discussion < Edge
  attr_accessor :forum, :page, :publisher
  parentable :forum, :page
  filterable pinned: {key: :pinned_at, values: {yes: 'NOT NULL', no: 'NULL'}}

  def self.default_per_page
    12
  end

  def parent
    forum || page
  end
  alias edgeable_record parent

  def self.includes_for_serializer
    [
      :parent,
      :default_vote_event,
      :default_cover_photo,
      creator: :profileable,
      trash_activity: {},
      untrash_activity: {},
      argu_publication: {},
      published_publications: {}
    ]
  end
end
