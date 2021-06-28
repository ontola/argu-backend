# frozen_string_literal: true

class MoveForm < ApplicationForm
  field :new_parent_id,
        max_count: 1,
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
