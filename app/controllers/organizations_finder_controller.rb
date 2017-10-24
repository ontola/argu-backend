# frozen_string_literal: true

class OrganizationsFinderController < AuthorizedController
  def show
    respond_to do |format|
      format.json_api do
        render json: authenticated_resource.parent_model(:page), include: [navigations_menu: [menus: :menus]]
      end
    end
  end

  private

  def authenticated_resource!
    resource_from_iri(params[:iri]) || LinkedRecord.find_or_fetch_by_iri(params[:iri])
  end

  def current_forum; end
end
