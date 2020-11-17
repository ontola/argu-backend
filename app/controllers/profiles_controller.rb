# frozen_string_literal: true

class ProfilesController < AuthorizedController
  active_response :show

  # GET /profiles/setup
  def setup
    active_response_block do
      @authenticated_resource = user_or_redirect
      @profile = @authenticated_resource.profile
      respond_with_redirect location: redirect_url || @authenticated_resource.iri.path
    end
  end

  private

  def authenticated_resource
    @authenticated_resource ||=
      Shortname.find_resource(params[:id])&.profile || Profile.find_by(id: params[:id]) || current_user.profile
  end

  def permit_params
    pm = params.require(:profile).permit(*policy(@profile || authenticated_resource).permitted_attributes).to_h
    merge_photo_params(pm)
    pm
  end

  def redirect_url
    return if authenticated_resource.try(:redirect_url).blank?

    redirect_url = authenticated_resource.redirect_url
    authenticated_resource.update redirect_url: ''
    redirect_url
  end

  def setup_permit_params
    pp = params.require(:user).permit(*policy(authenticated_resource || User).permitted_attributes).to_h
    merge_photo_params(pp)
    merge_placement_params(pp, User)
    pp
  end

  def user_or_redirect(redirect = nil)
    raise Argu::Errors::Unauthorized.new(redirect_url: redirect) if current_user.guest?

    current_user
  end
end
