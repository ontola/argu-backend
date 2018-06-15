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
    10
  end
end
