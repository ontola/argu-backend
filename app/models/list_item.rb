# frozen_string_literal: true

class ListItem < ApplicationRecord
  include Ldable
  belongs_to :listable, polymorphic: true, inverse_of: :list_items

  contextualize_with_id(&:iri)
end
