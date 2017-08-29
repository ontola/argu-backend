# frozen_string_literal: true

module ArguRDF
  class RDFResourceSerializer < BaseSerializer
    include RDFSerializer

    attributes :id

    has_one :agenda_item_collection
  end
end
