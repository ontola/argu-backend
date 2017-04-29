# frozen_string_literal: true
class SourcesController < ServiceController
  def settings
    prepend_view_path 'app/views/sources'

    render locals: {
      active: tab,
      tab: tab,
      resource: resource_by_id
    }
  end

  private

  def resource_by_id
    @_resource_by_id ||= Source.find_by!(shortname: params[:id])
  end

  def tab
    tab_param = params[:tab] || params[:source].try(:[], :tab)
    policy(authenticated_resource).verify_tab(tab_param)
  end

  def redirect_model_success(resource)
    settings_page_source_path(resource.page, resource, tab: tab)
  end

  def update_respond_failure_html(resource)
    render 'settings',
           locals: {
             active: tab,
             tab: tab,
             resource: resource
           }
  end
end
