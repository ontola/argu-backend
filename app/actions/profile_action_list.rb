# frozen_string_literal: true

class ProfileActionList < EdgeActionList
  private

  def update_url
    RDF::DynamicURI(expand_uri_template(:profiles_iri, id: resource.id, with_hostname: true))
  end
end
