# frozen_string_literal: true

class BannersController < ServiceController
  private

  def create_failure_html
    render_settings(:new, authenticated_resource, authenticated_resource.forum)
  end

  def edit_success_html
    render_settings(:edit, authenticated_resource, authenticated_resource.forum)
  end

  def new_success_html
    render_settings(:new, authenticated_resource, parent_resource!)
  end

  def redirect_location
    settings_iri_path(authenticated_resource.forum, tab: :banners)
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

  def resource_new_params
    HashWithIndifferentAccess.new(
      forum: parent_resource!,
      publisher: current_user
    )
  end

  def update_failure_html
    render_settings(:edit, authenticated_resource, authenticated_resource.forum)
  end

  def tree_root_id
    parent_resource&.root_id
  end
end
