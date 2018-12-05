# frozen_string_literal: true

class ListItem < ApplicationRecord
  belongs_to :listable, polymorphic: true, inverse_of: :list_items
end
