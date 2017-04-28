# frozen_string_literal: true
class BannersController < ServiceController
  include NestedResourceHelper

  private

  def create_respond_blocks_failure(resource, format)
    format.html do
      render 'forums/settings',
             locals: {
               banner: banner,
               tab: 'banners/new',
               active: 'banners'
             }
    end
    format.json { render json: resource, status: :created, location: resource }
    format.json_api { render json: resource, status: :created, location: resource }
  end

  def edit_respond_blocks_success(resource, format)
    format.html do
      render 'forums/settings',
             locals: {
               banner: resource,
               resource: resource.forum,
               tab: 'banners/edit',
               active: 'banners'
             }
    end
    format.json { render json: resource }
  end

  def new_resource_from_params
    controller_class.new resource_new_params
  end

  def new_respond_blocks_success(resource, format)
    format.html do
      render 'forums/settings',
             locals: {
               banner: resource,
               resource: get_parent_resource,
               tab: 'banners/new',
               active: 'banners'
             }
    end
    format.json { render json: resource }
  end

  def redirect_model_failure(resource)
    settings_forum_path(resource.forum, tab: :banners)
  end

  def redirect_model_success(resource)
    settings_forum_path(resource.forum, tab: :banners)
  end

  def update_respond_blocks_failure
    format.html do
      render 'forums/settings',
             locals: {
               banner: banner,
               tab: 'banners/edit',
               active: 'banners'
             }
    end
    format.json { render json: resource.errors, status: :unprocessable_entity }
    format.json_api { render json_api_error(422, resource.errors) }
  end
end
