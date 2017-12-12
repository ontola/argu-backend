# frozen_string_literal: true

class OrganizationsFinderController < AuthorizedController
  include NestedResourceHelper

  def show
    @organization = authenticated_resource.parent_model(:page) || raise(ActiveRecord::RecordNotFound)
    respond_to do |format|
      format.n3 { render n3: Blank.new, meta: meta }
      format.nt { render nt: Blank.new, meta: meta }
    end
  end

  private

  def authenticated_resource!
    @resource ||= resource_from_param if resource_from_param.respond_to?(:parent_model)
  end

  def current_forum; end

  def meta
    [
      [
        RDF::URI(Rails.application.routes.url_helpers.o_find_url(iri: params[:iri])),
        NS::ARGU[:contains],
        RDF::URI(@organization.iri)
      ]
    ]
  end

  def resource_from_param
    resource_from_iri(params[:iri]) || parent_from_iri(params[:iri]) || LinkedRecord.find_or_fetch_by_iri(params[:iri])
  end
end
