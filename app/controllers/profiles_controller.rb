class ProfilesController < ApplicationController
  def index
    authorize Profile, :index?
    @resource = Shortname.find_resource 'nederland' # params[:thing]
    # authorize @resource, :list_members?

    scope = policy_scope(@resource.members)

    if current_user.present?
      if params[:q].present?
        # This is a working mess.
        q = params[:q].gsub(' ', '|')
        @profiles = Profile.where(profileable_type: 'User',
                                  profileable_id: User.where(finished_intro: true)
                                                      .joins(:shortname)
                                                      .where('lower(shortname) SIMILAR TO lower(?) OR ' +
                                                             'lower(first_name) SIMILAR TO lower(?) OR ' +
                                                             'lower(last_name) SIMILAR TO lower(?)',
                                                             "%#{q}%",
                                                             "%#{q}%",
                                                             "%#{q}%")
                                                      .pluck(:owner_id))

        if params[:things] && params[:things].split(',').include?('pages')
          @profiles += Profile.where(is_public: true).where('lower(name) SIMILAR TO lower(?)', "%#{q}%")#.page params[:profile] # Pages
        end
      end
    end
  end

  #GET /1/edit
  def edit
    @resource = Shortname.find_resource(params[:id])
    @profile = @resource.profile
    authorize @profile, :edit?

    if @resource.finished_intro?
      respond_to do |format|
        format.html { render profile_edit_view_path(@resource) }
      end
    else
      @resource.build_home_placement(place: Place.find_or_fetch_by(country_code: 'NL', postcode: nil))
      respond_to do |format|
        format.html { render profile_edit_view_path(@resource), layout: 'closed' } # edit.html.erb
      end
    end
  end

  #PUT /1
  def update
    @resource = Shortname.find_resource(params[:id])
    @profile = @resource.profile
    authorize @profile, :update?

    updated = nil
    Profile.transaction do
      updated = @profile.update permit_params

      if @profile.profileable.class == User
        updated = updated && @profile.profileable.update_attributes(user_profileable_params)
        if (!@resource.finished_intro?) && has_valid_token?(@resource)
          get_access_tokens(@resource).compact.each do |at|
            @profile.memberships.find_or_create_by(forum: at.item) if at.item.class == Forum
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
        format.html { render profile_edit_view_path(@resource) }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def permit_params
    params.require(:profile).permit(*policy(@profile || Profile).permitted_attributes)
  end

  def user_profileable_params
    params.require(:profile)
          .require(:profileable_attributes)
          .permit :first_name, :middle_name, :last_name, :birthday, home_placement_attributes: [:postal_code, :country_code, :id]
  end

  def profile_update_path
    @user.finished_intro? ? profile_path(@user.url) : selector_forums_path
  end

  def profile_edit_view_path(resource)
    "#{resource.class_name}/profiles/edit"
  end
end
