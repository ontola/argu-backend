# frozen_string_literal: true

class BannersController < ServiceController
  include NestedResourceHelper

  private

  def create_respond_failure_html(resource)
    render_settings(:new, resource, resource.forum)
  end

  def edit_respond_success_html(resource)
    render_settings(:edit, resource, resource.forum)
  end

  def new_respond_success_html(resource)
    render_settings(:new, resource, parent_resource!)
  end

  def redirect_model_failure(resource)
    settings_forum_path(resource.forum, tab: :banners)
  end

  def redirect_model_success(resource)
    settings_forum_path(resource.forum, tab: :banners)
  end

  def redirect_url
    if request.method == 'GET'
      [request.path, request.query_string].reject(&:blank?).join('?')
    else
      settings_forum_path(authenticated_resource.forum, tab: :banners)
    end
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

  def respond_with_201(resource, format)
    return super unless %i[json json_api].include?(format)

    render json: resource, status: :created
  end

  def update_respond_failure_html(resource)
    render_settings(:edit, resource, resource.forum)
  end
end
