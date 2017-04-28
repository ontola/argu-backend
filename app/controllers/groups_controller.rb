# frozen_string_literal: true
class GroupsController < ServiceController
  include NestedResourceHelper

  def show
    respond_to do |format|
      format.html do
        if params[:welcome] == 'true'
          flash[:notice] = t('group_memberships.welcome', group: authenticated_resource.name)
        end
        redirect_to page_path(authenticated_resource.page)
      end
      format.json_api { render json: authenticated_resource, include: %i(organization) }
    end
  end

  def settings
    if tab == 'members'
      @members = resource
                 .group_memberships
                 .includes(member: {profileable: :shortname})
                 .page(params[:page])
    end
    render locals: {
      tab: tab,
      active: tab,
      resource: resource_by_id
    }
  end

  def delete
    locals = {
      group: authenticated_resource!,
      group_memberships_count: authenticated_resource!.group_memberships.count
    }
    respond_to do |format|
      format.html { render locals: locals }
      format.js { render locals: locals }
    end
  end

  private

  def create_respond_blocks_failure(resource, format)
    format.html do
      render 'forums/settings',
             locals: {
               tab: 'groups/new',
               active: 'groups',
               group: resource
             }
    end
    format.json { render json: resource.errors, status: :unprocessable_entity }
    format.json_api { json_api_error(422, resource.errors) }
    format.js { head :bad_request }
  end

  def new_respond_blocks_success(resource, format)
    format.js { render js: "window.location = #{request.url.to_json}" }
    format.html do
      render 'pages/settings', locals: {
        tab: 'groups/new',
        active: 'groups',
        group: resource,
        resource: resource.page
      }
    end
    format.json { render json: resource }
  end

  def redirect_model_success(resource)
    settings_page_path(resource.page, tab: :groups)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      page: get_parent_resource
    )
  end

  def tab
    policy(resource_by_id || Group).verify_tab(params[:tab] || params[:group].try(:[], :tab))
  end

  def update_respond_blocks_failure
    format.html do
      render 'settings',
             locals: {
               tab: tab,
               active: tab,
               resource: group
             }
    end
    format.json { render json: resource.errors, status: :unprocessable_entity }
    format.json_api { render json_api_error(422, resource.errors) }
  end
end
