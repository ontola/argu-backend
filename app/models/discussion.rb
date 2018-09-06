# frozen_string_literal: true

class Discussion
  include ApplicationModel
  include ActiveModel::Model

  include Ldable
  include Iriable
  include Parentable

  attr_accessor :forum, :page, :publisher
  parentable :forum, :page
  alias edgeable_record parent

  filterable pinned: {key: :pinned_at, values: {yes: 'NOT NULL', no: 'NULL'}}

  def self.default_per_page
    12
  end

  def self.includes_for_serializer
    [:parent, :default_vote_event, :default_cover_photo, creator: :profileable]
  end
end
