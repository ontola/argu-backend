# frozen_string_literal: true
class CollectionSerializer < BaseSerializer
  belongs_to :parent
  has_many :collection_entries
end
