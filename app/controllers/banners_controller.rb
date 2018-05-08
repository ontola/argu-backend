# frozen_string_literal: true

class BannersController < ServiceController
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
    settings_iri_path(resource.forum, tab: :banners)
  end

  def redirect_model_success(resource)
    settings_iri_path(resource.forum, tab: :banners)
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
    render_settings(:edit, resource, resource.forum)
  end

  def tree_root_id
    parent_edge&.root_id
  end
end
