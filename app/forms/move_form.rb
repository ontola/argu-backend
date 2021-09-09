# frozen_string_literal: true

class MoveForm < ApplicationForm
  self.abstract_form = true

  field :new_parent_id,
        max_count: 1,
        path: NS.argu[:moveTo],
        sh_in: lambda {
          ActsAsTenant.current_tenant.search_result_collection(
            filter: {
              NS.rdfv.type => [
                NS.argu[:ContainerNode],
                Question.iri
              ]
            }
          ).iri
        }
end
