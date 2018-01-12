# frozen_string_literal: true

class Discussion
  include ActiveModel::Model
  include Iriable
  include Parentable
  attr_accessor :forum, :page, :publisher
  parentable :forum, :page
end
