# frozen_string_literal: true

class BannerManagementsController < EdgeableController
  private

  def ld_action_resource(_resource)
    Banner.root_collection
  end

  def default_form_options(action)
    opts = super
    same_as = BannerManagement.root_collection.action(:create, user_context)

    opts.merge(
      meta: [
        RDF::Statement.new(same_as.iri, NS::OWL.sameAs, opts[:action].iri)
      ]
    )
  end
end
