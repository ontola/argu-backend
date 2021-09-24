# frozen_string_literal: true

class TransferForm < ApplicationForm
  self.abstract_form = true

  field :transfer_to,
        min_count: 1,
        max_count: 1,
        path: NS.argu[:transferTo],
        sh_in: -> { User.root_collection.search_result_collection.iri }
end
