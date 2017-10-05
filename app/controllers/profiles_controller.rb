# frozen_string_literal: true

class ProfilesController < ApplicationController
  include SettingsHelper

  def index
    return if current_user.guest? || params[:q].blank?
    # This is a working mess.
    q = params[:q].tr(' ', '|')
    @profiles = policy_scope(Profile)
                  .where(profileable_type: 'User',
                         profileable_id: User
                                           .joins(:shortname)
                                           .where('lower(shortname) SIMILAR TO lower(?) OR ' \
                                                    'lower(first_name) SIMILAR TO lower(?) OR ' \
                                                    'lower(last_name) SIMILAR TO lower(?)',
                                                  "%#{q}%",
                                                  "%#{q}%",
                                                  "%#{q}%")
                                           .pluck(:owner_id))
                  .includes(:default_profile_photo, profileable: %i[shortname email_addresses])

    return unless params[:things] && params[:things].split(',').include?('pages')
    @profiles += policy_scope(Profile)
                   .where('lower(name) SIMILAR TO lower(?)', "%#{q}%")
  end

  # GET /p/shortname/edit
  def edit
    @resource = Shortname.find_resource(params[:id])
    authorize @resource, :settings?
    if @resource.is_a? User
      redirect_to url_for([:settings, tab: :profile])
    else
      redirect_to url_for([:settings, @resource, tab: :profile])
    end
  end

  # GET /profiles/setup
  def setup
    @resource = user_or_redirect
    @profile = @resource.profile
    authorize @profile, :edit?

    respond_to do |format|
      format.html do
        render 'users/profiles/setup',
               locals: {profile: @profile, resource: @resource}
      end
    end
  end

  # PUT /profiles/setup
  def setup!
    @resource = user_or_redirect
    @profile = @resource.profile
    authorize @profile, :update?

    respond_to do |format|
      if @resource.update(setup_permit_params)
        format.html do
          redirect_to redirect_url || dual_profile_url(@profile), notice: 'Profile was successfully updated.'
        end
        format.json { respond_with_204(resource, :json) }
        format.json_api { respond_with_204(resource, :json_api) }
      else
        format.html do
          render 'users/profiles/setup',
                 locals: {profile: @profile, resource: @resource}
        end
        format.json { respond_with_422(@profile, :json) }
        format.json_api { respond_with_422(@profile, :json_api) }
      end
    end
  end

  private

  def permit_params
    pm = params.require(:profile).permit(*policy(@profile || Profile).permitted_attributes).to_h
    merge_photo_params(pm, @resource.class)
    pm
  end

  def redirect_url
    return cookies.delete(:token) if cookies[:token].present?
    return if @resource.try(:r).blank?
    r = URI.decode(@resource.r)
    @resource.update r: ''
    r_opts = r_to_url_options(r)[0]
    r_opts.present? ? r_opts.merge(Addressable::URI.parse(r).query_values || {}) : r
  end

  def setup_permit_params
    pp = params.require(:user).permit(*policy(@resource || User).permitted_attributes(true)).to_h
    merge_photo_params(pp, @resource.class)
    merge_placement_params(pp, User)
    pp
  end

  def user_or_redirect(redirect = nil)
    raise Argu::NotAUserError.new(r: redirect) if current_user.guest?
    current_user
  end
end
