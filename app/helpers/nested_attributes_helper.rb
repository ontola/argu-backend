# frozen_string_literal: true

module NestedAttributesHelper
  # @param [class] type The type of the placement#placeable
  # @param [Forum] forum The forum the placement should be tenantanized in
  def placement_params(type, forum = nil)
    attrs = {publisher: current_user, creator: current_profile, forum: nil}
    attrs[:forum] = forum unless type == User
    attrs
  end

  def merge_placement_params(permit_params, klass)
    home_placement = permit_params[:home_placement_attributes]
    home_placement&.merge!(placement_params(klass))

    permit_params
  end
end
