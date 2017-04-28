# frozen_string_literal: true
class SourcesController < ServiceController
  def settings
    prepend_view_path 'app/views/sources'

    render locals: {
      tab: tab,
      active: tab,
      resource: resource_by_id
    }
  end

  private

  def resource_by_id
    @_resource_by_id ||= Source.find_by!(shortname: params[:id])
  end

  def tab
    policy(authenticated_resource).verify_tab(params[:tab] || params[:source].try(:[], :tab))
  end

  def redirect_model_success(resource)
    settings_page_source_path(resource.page, resource, tab: tab)
  end

  def update_respond_blocks_failure(resource, format)
    format.html do
      render 'settings',
             locals: {
               tab: tab,
               active: tab
             }
    end
    format.json { render json: resource.errors, status: :unprocessable_entity }
    format.json_api { render json_api_error(422, resource.errors) }
  end
end
