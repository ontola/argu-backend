class ProfilesController < ApplicationController
  include SettingsHelper

  def index
    authorize Profile, :index?
    @resource = Shortname.find_resource 'nederland' # params[:thing]
    # authorize @resource, :list_members?

    scope = policy_scope(@resource.members_group.members)

    if current_user.present?
      if params[:q].present?
        # This is a working mess.
        q = params[:q].gsub(' ', '|')
        @profiles = Profile
                      .where(profileable_type: 'User',
                             profileable_id: User.where(finished_intro: true)
                                               .joins(:shortname)
                                               .where('lower(shortname) SIMILAR TO lower(?) OR ' +
                                                        'lower(first_name) SIMILAR TO lower(?) OR ' +
                                                        'lower(last_name) SIMILAR TO lower(?)',
                                                      "%#{q}%",
                                                      "%#{q}%",
                                                      "%#{q}%")
                                               .pluck(:owner_id))
                      .includes(:default_profile_photo, profileable: :shortname)

        if params[:things] && params[:things].split(',').include?('pages')
          @profiles += Profile
                         .where(is_public: true)
                         .where('lower(name) SIMILAR TO lower(?)', "%#{q}%")
          # .page params[:profile] # Pages
        end
      end
    end
  end

  #GET /p/shortname/edit
  def edit
    @resource = Shortname.find_resource(params[:id])
    authorize @resource, :settings?
    if @resource.is_a? User
      redirect_to url_for([:settings, tab: :profile])
    else
      redirect_to url_for([:settings, @resource, tab: :profile])
    end
  end

  #GET /profiles/setup
  def setup
    @resource = user_or_redirect
    @profile = @resource.profile
    authorize @profile, :edit?

    if @resource.finished_intro?
      redirect_to settings_url_for(@resource, tab: :profile)
    else
      respond_to do |format|
        format.html do
          render 'users/profiles/setup',
                 locals: {profile: @profile, resource: @resource},
                 layout: 'closed'
        end
      end
    end
  end

  #PUT /profiles/setup
  def setup!
    @resource = user_or_redirect
    @profile = @resource.profile
    authorize @profile, :update?

    updated = nil
    Profile.transaction do
      updated = @resource.update setup_permit_params
      if updated
        if has_valid_token?(@resource)
          get_access_tokens(@resource).compact.each do |at|
            @profile.group_memberships.find_or_create_by(group: at.item.members_group) if at.item.class == Forum
          end
        end
        @resource.update_column :finished_intro, true
      end
    end

    respond_to do |format|
      if updated && @resource.try(:r).present?
        r = URI.decode(@resource.r)
        @resource.update r: ''
        r_opts = r_to_url_options(r)[0].merge(Addressable::URI.parse(r).query_values || {})
        format.html { redirect_to r_opts }
      elsif updated
        format.html { redirect_to dual_profile_url(@profile), notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html do
          render 'users/profiles/setup',
                 locals: {profile: @profile, resource: @resource},
                 layout: 'closed'
        end
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def permit_params
    pm = params.require(:profile).permit(*policy(@profile || Profile).permitted_attributes).to_h
    merge_photo_params(pm, @resource.class)
    pm
  end

  def setup_permit_params
    pp = params.require(:user).permit(*policy(@resource || User).permitted_attributes(true)).to_h
    merge_photo_params(pp, @resource.class)
    merge_placement_params(pp, User)
    pp
  end

  def user_or_redirect(redirect = nil)
    raise Argu::NotAUserError.new(r: redirect) if current_user.blank?
    current_user
  end
end
