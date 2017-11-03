# frozen_string_literal: true

class OrganizationsFinderController < AuthorizedController
  def show
    organization = authenticated_resource.parent_model(:page)
    respond_to do |format|
      format.json_api do
        render json: organization, include: include_show
      end
      format.n3 do
        s = ActiveModelSerializers::Adapter::N3::Triple.new(
          RDF::URI(Rails.application.routes.url_helpers.o_find_url(iri: params[:iri])),
          NS::OWL[:sameAs],
          RDF::URI(organization.iri)
        )
        render n3: organization,
               meta: [s],
               include: include_show
      end
    end
  end

  private

  def authenticated_resource!
    resource_from_iri(params[:iri]) || LinkedRecord.find_or_fetch_by_iri(params[:iri])
  end

  def current_forum; end

  def include_show
    [navigations_menu: [menus: :menus]]
  end
end
