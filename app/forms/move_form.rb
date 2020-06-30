# frozen_string_literal: true

class MoveForm < ApplicationForm
  field :new_parent_id,
        max_count: 1,
        sh_in: -> { move_options }

  def move_options
    ActsAsTenant.current_tenant.forums.flat_map { |forum| [forum.iri] + forum.questions.map(&:iri) }
  end
end
