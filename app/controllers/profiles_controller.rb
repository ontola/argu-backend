# frozen_string_literal: true

class ProfilesController < AuthorizedController
  include SettingsHelper
  include UriTemplateHelper
  active_response :edit, :show

  def index # rubocop:disable Metrics/AbcSize
    return if current_user.guest? || params[:q].blank?
    q = params[:q].tr(' ', '|')
    @profiles = search_scope(q).includes(:default_profile_photo, profileable: %i[shortname email_addresses])
    return unless params[:things]&.split(',')&.include?('pages')
    @profiles += policy_scope(Profile)
                   .where('lower(name) SIMILAR TO lower(?)', "%#{q}%")
  end

  # GET /profiles/setup
  def setup
    active_response_block do
      @resource = user_or_redirect
      @profile = @resource.profile
      if active_response_type == :html
        @resource.build_home_placement if @resource.home_placement.nil?

        respond_with_form(
          locals: {profile: @profile, resource: @resource},
          view: 'users/profiles/setup'
        )
      else
        respond_with_redirect location: redirect_url || dual_profile_url(@profile)
      end
    end
  end

  # PUT /profiles/setup
  def setup!
    @resource = user_or_redirect
    @profile = @resource.profile

    respond_to do |format|
      if @resource.update(setup_permit_params)
        format.html do
          redirect_to redirect_url || dual_profile_url(@profile), notice: 'Profile was successfully updated.'
        end
      else
        format.html do
          render 'users/profiles/setup',
                 locals: {profile: @profile, resource: @resource}
        end
      end
    end
  end

  private

  def current_resource
    @current_resource ||=
      Shortname.find_resource(params[:id])&.profile || Profile.find_by(id: params[:id]) || current_user.profile
  end
  alias authenticated_resource current_resource

  def edit_success_html
    if current_resource.profileable.is_a? User
      redirect_to settings_iri('/u', tab: :profile)
    else
      redirect_to settings_iri(current_resource.profileable, tab: :profile)
    end
  end

  def permit_params
    pm = params.require(:profile).permit(*policy(@profile || current_resource).permitted_attributes).to_h
    merge_photo_params(pm, @resource.class)
    pm
  end

  def redirect_url
    return cookies.delete(:token) if cookies[:token].present?
    return if @resource.try(:r).blank?
    r = @resource.r
    @resource.update r: ''
    r
  end

  def search_scope(q)
    scope =
      policy_scope(Profile)
        .where(profileable_type: 'User')
        .joins("INNER JOIN users ON profiles.profileable_id = users.uuid AND profiles.profileable_type = 'User'")
        .joins("LEFT JOIN shortnames ON shortnames.owner_id = users.uuid AND shortnames.owner_type = 'User'")
    wheres = [
      'lower(shortname) SIMILAR TO lower(?)',
      'lower(first_name) SIMILAR TO lower(?)',
      'lower(last_name) SIMILAR TO lower(?)'
    ]
    if current_user.is_staff?
      scope = scope.joins('INNER JOIN email_addresses ON email_addresses.user_id = users.id')
      wheres << 'email_addresses.email SIMILAR TO lower(?)'
    end
    scope.where(wheres.join(' OR '), *wheres.map { |_| "%#{q}%" }).distinct
  end

  def setup_permit_params
    pp = params.require(:user).permit(*policy(@resource || User).permitted_attribute_names(true)).to_h
    merge_photo_params(pp, @resource.class)
    merge_placement_params(pp, User)
    pp
  end

  def show_success_html
    redirect_to current_resource.profileable
  end

  def user_or_redirect(redirect = nil)
    raise Argu::Errors::Unauthorized.new(r: redirect) if current_user.guest?
    current_user
  end
end
