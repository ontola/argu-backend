module PhotosHelper
  # Used to make sure the image_cached attribute is accessible in the form
  def photo_for_form(resource, used_as)
    resource.photos.detect {|photo| photo.persisted? ? photo == resource.send(used_as) : photo.used_as == used_as.to_s}
  end

  # @param [class] type The type of the photo#about
  # @param [Forum] forum The forum the photo should be tenantanized in
  def photo_params(type, forum = nil)
    attrs = {publisher: current_user, creator: current_profile, forum: nil}
    attrs[:forum] = forum unless type == Page || type == User
    attrs
  end

  def merge_photo_params(permit_params, klass)
    profile = permit_params.dig(*photo_params_nested_path(:default_profile_photo_attributes))
    profile.merge!(photo_params(klass)) if profile

    cover = permit_params.dig(*photo_params_nested_path(:default_cover_photo_attributes))
    cover.merge!(photo_params(klass)) if cover

    permit_params
  end

  def photo_params_nested_path(type)
    [*photo_params_nesting_path, type].compact
  end

  def photo_params_nesting_path
    [:profile_attributes]
  end
end
