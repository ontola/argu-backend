# frozen_string_literal: true

class ProfileActionList < EdgeActionList
  has_action(
    :update,
    update_options.merge(
      url: -> { RDF::DynamicURI(expand_uri_template(:profiles_iri, id: resource.id, with_hostname: true)) }
    )
  )
end
