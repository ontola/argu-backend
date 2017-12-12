# frozen_string_literal: true

class SourcesController < ServiceController
  def show
    return unless policy(resource_by_id).show?

    respond_to do |format|
      format.html do
        redirect_to settings_page_source_path(authenticated_resource.parent_model, authenticated_resource)
      end
      format.json_api do
        render json: authenticated_resource,
               include: include_show
      end
      format.nt do
        render nt: authenticated_resource,
               include: include_show
      end
    end
  end

  def settings
    prepend_view_path 'app/views/sources'

    render locals: {
      active: tab!,
      tab: tab!,
      resource: resource_by_id
    }
  end

  private

  def include_show
    [
      motion_collection: inc_nested_collection,
      question_collection: inc_nested_collection
    ]
  end

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

  def tab!
    @verified_tab ||= policy(authenticated_resource).verify_tab(tab)
  end

  def tab
    @tab ||= params[:tab] || params[:source].try(:[], :tab) || policy(authenticated_resource).default_tab
  end

  def redirect_model_success(resource)
    return super unless resource.persisted?
    settings_page_source_path(resource.page, resource, tab: tab)
  end

  def update_respond_failure_html(resource)
    render 'settings',
           locals: {
             active: tab!,
             tab: tab!,
             resource: resource
           }
  end
end
