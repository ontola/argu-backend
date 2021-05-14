# frozen_string_literal: true

class BannersController < EdgeableController
  private

  # Overwritten because the super method checks if the resource #is_published?
  def create_meta
    resource_added_delta(authenticated_resource)
  end

  def redirect_location
    settings_iri(authenticated_resource.root, tab: :banners)
  end

  def update_meta
    return super unless current_resource.dismiss_action

    super + [[current_resource.dismiss_action, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)]]
  end
end
