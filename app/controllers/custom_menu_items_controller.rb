# frozen_string_literal: true

class CustomMenuItemsController < ParentableController
  private

  def redirect_location
    settings_iri(parent_resource, tab: :custom_menu_items)
  end

  def update_meta
    create_meta
  end

  def update_success
    add_exec_action_header(response.headers, ontola_redirect_action(redirect_location))
    respond_with_resource(resource: current_resource, meta: update_meta)
  end
end
