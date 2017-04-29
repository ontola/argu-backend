# frozen_string_literal: true
class BannersController < ServiceController
  include NestedResourceHelper

  private

  def create_respond_failure_html(resource)
    render_settings(:new, resource)
  end

  def edit_respond_success_html(resource)
    render_settings(:edit, resource, resource.forum)
  end

  def new_resource_from_params
    controller_class.new resource_new_params
  end

  def new_respond_success_html(resource)
    render_settings(:new, resource, get_parent_resource)
  end

  def redirect_model_failure(resource)
    settings_forum_path(resource.forum, tab: :banners)
  end

  def redirect_model_success(resource)
    settings_forum_path(resource.forum, tab: :banners)
  end

  def render_settings(tab, banner, resource = nil)
    locals = {
      banner: banner,
      tab: "banners/#{tab}",
      active: 'banners'
    }
    locals[:resource] = resource
    render 'forums/settings',
           locals: locals
  end

  def update_respond_failure_html(resource)
    render_settings(:edit, resource)
  end
end
