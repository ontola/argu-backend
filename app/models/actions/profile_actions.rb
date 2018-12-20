# frozen_string_literal: true

module Actions
  class ProfileActions < EdgeActions
    private

    def update_url
      RDF::DynamicURI(expand_uri_template(:profiles_iri, id: resource.id, with_hostname: true))
    end
  end
end
