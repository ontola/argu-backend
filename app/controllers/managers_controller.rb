class ManagersController < ApplicationController

  def new
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :edit?
    @membership = @forum.managers.new
  end

  def create
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :update?
    @membership = @forum.memberships.find_or_initialize_by(profile_id: params[:profile_id])

    Pundit.policy!(pundit_user, @forum).add_manager?(@membership)

    respond_to do |format|
      if @membership.update role: Membership.roles[:manager]
        format.html { redirect_to url_for([:settings, @forum, tab: :managers]) }
      elsif @membership.present?
        format.html { render 'new' }
      else
        format.html { render 404 }
      end
    end
  end

  def destroy
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :update?
    @manager = @forum.memberships.find_by(profile_id: params[:id])

    Pundit.policy!(pundit_user, @forum).remove_manager?(@manager)

    respond_to do |format|
      if @manager.update role: Membership.roles[:member]
        format.html { redirect_to url_for([:settings, @forum, tab: :managers]) }
      else
        flash[:error] = t('errors.messages.not_saved')
        format.html { redirect_to :back }
      end
    end
  end

private
    def permit_params
      params.permit(*policy(@forum || Forum).permitted_attributes)
    end
end