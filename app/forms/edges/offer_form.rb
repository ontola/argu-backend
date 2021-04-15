# frozen_string_literal: true

class OfferForm < ApplicationForm
  visibility_text

  field :product_id,
        datatype: NS::XSD[:string],
        sh_in: -> { ActsAsTenant.current_tenant.search_result(filter: {NS::RDFV.type => [Motion.iri]}).iri }
  field :price, input_field: MoneyInput

  footer do
    actor_selector
  end
end
