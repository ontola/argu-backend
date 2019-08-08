# frozen_string_literal: true

class ProfileActionList < EdgeActionList
  has_action(
    :update,
    update_options.merge(
      url: -> { iri_from_template(:profiles_iri, id: resource.id) }
    )
  )
end
