# frozen_string_literal: true

class CustomMenuItemsController < ParentableController
  private

  def redirect_location
    settings_iri(parent_resource, tab: :custom_menu_items)
  end

  def update_meta
    super + resource_added_delta(current_resource)
  end
end
