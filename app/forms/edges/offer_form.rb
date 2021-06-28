# frozen_string_literal: true

class OfferForm < ApplicationForm
  visibility_text

  field :product_id,
        datatype: NS.xsd.string,
        sh_in: -> { Motion.root_collection.search_result_collection.iri }
  field :price, input_field: MoneyInput

  footer do
    actor_selector
  end
end
