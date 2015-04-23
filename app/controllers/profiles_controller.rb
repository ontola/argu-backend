class ProfilesController < ApplicationController

  def index
    @resource = Shortname.find_resource 'nederland'  # params[:thing]
    #authorize @resource, :list_members?

    scope = policy_scope(@resource.members)

    if current_user.present?
      if params[:q].present?
        # This is a working mess.
        @profiles = Profile.where(is_public: true).where('lower(name) LIKE lower(?)', "%#{params[:q]}%").page params[:profile] # Pages
        @profiles += Profile.where(is_public: true).where(profileable_type: 'User',
                                                         profileable_id: User.where(finished_intro: true).joins(:shortname)
                                                                             .where('lower(shortname) LIKE lower(?) OR '\
                                                                                    'lower(first_name) LIKE lower(?) OR '\
                                                                                    'lower(last_name) LIKE lower(?)',
                                                                                    "%#{params[:q]}%",
                                                                                    "%#{params[:q]}%",
                                                                                    "%#{params[:q]}%").pluck(:owner_id))
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
          get_access_tokens(@resource).each do |at|
            @profile.memberships.find_or_create_by(forum: at.item) if at.item.class == Forum
          end
        end
        @resource.update_column :finished_intro, true
      end
    end

    respond_to do |format|
      if updated && @resource.try(:r).present?
        r = @resource.r
        @resource.update r: ''
        format.html { redirect_to r,
                      status: r.match(/\/v(\?|\/)|\/c(\?|\/)/) ? 307 : 302 }
      elsif updated
        format.html { redirect_to dual_profile_path(@profile), notice: 'Profile was successfully updated.' }
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
    params.require(:profile).require(:profileable_attributes).permit :first_name, :middle_name, :last_name
  end

  def profile_update_path
    @user.finished_intro? ? profile_path(@user.url) : selector_forums_path
  end

  def profile_edit_view_path(resource)
    "#{resource.class_name}/profiles/edit"
  end
end
