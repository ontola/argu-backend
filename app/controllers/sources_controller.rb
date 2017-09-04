# frozen_string_literal: true

class SourcesController < ServiceController
  def show
    return unless policy(resource_by_id).show?

    respond_to do |format|
      format.json_api do
        render json: authenticated_resource,
               include: [
                 motion_collection: INC_NESTED_COLLECTION,
                 question_collection: INC_NESTED_COLLECTION
               ]
      end
    end
  end

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
    @_resource_by_id ||= if (/[a-zA-Z]/i =~ params[:id]).nil?
                           Source.find_by(page_id: params[:page_id], id: params[:id])
                         else
                           Source.find_by(
                             page_id: Page.find_via_shortname!(params[:page_id]).id,
                             shortname: params[:id]
                           )
                         end
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
