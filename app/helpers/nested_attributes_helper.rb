# frozen_string_literal: true

module NestedAttributesHelper
  # @param [class] type The type of the photo#about
  # @param [symbol] used_as The type of photo, should be a valid enum value
  def photo_params(used_as)
    attrs = {publisher: current_user, creator: current_profile, forum: nil}
    attrs[:used_as] ||= used_as
    attrs
  end

  def merge_photo_params(permit_params)
    profile = permit_params.dig(*photo_params_nested_path(:default_profile_photo_attributes))
    profile&.reverse_merge!(photo_params(:profile_photo))

    cover = permit_params.dig(*photo_params_nested_path(:default_cover_photo_attributes))
    cover&.reverse_merge!(photo_params(:cover_photo))

    permit_params
  end

  def photo_params_nested_path(type)
    [*photo_params_nesting_path, type].compact
  end

  def photo_params_nesting_path
    [:profile_attributes]
  end

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
