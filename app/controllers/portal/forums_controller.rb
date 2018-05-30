# frozen_string_literal: true

class Portal::ForumsController < EdgeableController
  private

  def parent_resource
    Page.find_via_shortname_or_id(params[:page] || params[:page_id])
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      parent: parent_resource!
    )
  end

  def respond_with_form_js(resource)
    respond_js(
      "portal/#{controller_name}/form",
      resource: resource,
      controller_name.singularize.to_sym => resource
    )
  end
end
