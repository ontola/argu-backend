# frozen_string_literal: true

class Discussion
  include ApplicationModel
  include ActiveModel::Model

  enhance Createable

  include Iriable
  include Parentable

  attr_accessor :forum, :page, :publisher
  parentable :forum, :page
  alias edgeable_record parent

  def self.default_per_page
    12
  end

  def self.includes_for_serializer
    [:parent, :default_vote_event, :default_cover_photo, creator: :profileable]
  end
end
