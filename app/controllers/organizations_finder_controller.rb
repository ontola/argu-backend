# frozen_string_literal: true

class OrganizationsFinderController < AuthorizedController
  include NestedResourceHelper
  include UrlHelper

  def show
    @organization = authenticated_resource.ancestor(:page) || raise(ActiveRecord::RecordNotFound)
    respond_to do |format|
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { render type => Blank.new, meta: meta }
      end
    end
  end

  private

  def authenticated_resource!
    @resource ||= resource_from_param if resource_from_param.respond_to?(:parent)
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

  def parent_from_linked_record(iri)
    match = iri&.match(%r{#{Regexp.new argu_url}\/(.*)\/(.*)\/(lr|od)\/(.*)})
    return if match.nil?
    Page
      .joins(shortname: {}, children: :shortname)
      .find_by(shortnames: {shortname: match[1]}, shortnames_edges: {shortname: match[2]})
  end

  def resource_from_param
    resource_from_iri(params[:iri]) || parent_from_iri(params[:iri]) || parent_from_linked_record(params[:iri])
  end

  def tree_root_id
    authenticated_resource!.is_a?(Edge) ? authenticated_resource!.root_id : authenticated_resource!.try(:edge)&.root_id
  end
end
