class Pages::ManagersController < ApplicationController
  def new
    @page = Page.find_via_shortname params[:page_id]
    authorize @page, :edit?
    @membership = @page.managerships.new
  end

  def create
    @page = Page.find_via_shortname params[:page_id]
    authorize @page, :update?
    user = User.find_via_shortname params[:profile_id]
    @membership = @page.memberships.find_or_initialize_by(profile_id: user.profile.id)

    Pundit.policy!(pundit_user, @page).add_manager?(@membership)

    respond_to do |format|
      if @membership.update role: PageMembership.roles[:manager]
        format.html { redirect_to url_for([:settings, @page, tab: :managers]) }
      elsif @membership.present?
        format.html { render 'new' }
      else
        format.html { render 404 }
      end
    end
  end

  def destroy
    @page = Page.find_via_shortname params[:page_id]
    authorize @page, :update?
    @manager = @page.memberships.find_by(profile_id: params[:id])

    Pundit.policy!(pundit_user, @page).remove_manager?(@manager)

    respond_to do |format|
      if @manager.update role: PageMembership.roles[:member]
        format.html { redirect_to url_for([:settings, @page, tab: :managers]) }
      else
        flash[:error] = t('errors.messages.not_saved')
        format.html { redirect_to :back }
      end
    end
  end

private
    def permit_params
      params.permit(*policy(@page || Page).permitted_attributes)
    end
end
