# frozen_string_literal: true

class OrganizationsFinderController < AuthorizedController
  def show
    organization = authenticated_resource.parent_model(:page)
    respond_to do |format|
      format.n3 do
        s = ActiveModelSerializers::Adapter::N3::Triple.new(
          RDF::URI(Rails.application.routes.url_helpers.o_find_url(iri: params[:iri])),
          NS::ARGU[:contains],
          RDF::URI(organization.iri)
        )
        render n3: Blank.new,
               meta: [s]
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
