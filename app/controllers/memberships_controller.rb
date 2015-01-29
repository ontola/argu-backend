class MembershipsController < ApplicationController
  #responds_to :js

  def create
    forum = Forum.friendly.find params[:forum_id]
    authorize forum, :show?
    if current_profile.blank?
      render_register_modal(false)
    else
      @membership = Membership.new profile: current_profile, forum: forum, role: (permit_params[:role] || Membership.roles[:member])
      authorize @membership, :create?

      if @membership.save
        redirect_to params[:r].presence || @membership.forum,
                    status: request.fullpath.match(/vote|comments/) ? 307 : 302
      else
        render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
      end
    end
  end

  def update
    @membership = Forum.find params[:id]
    authorize @membership, :update?

    if @membership.update permit_params
      render 'settings'
    else
      render notifications: [{type: 'error', message: 'Fout tijdens het opslaan'}]
    end
  end

  def destroy
    @forum = Forum.friendly.find(params[:forum_id])
    authorize @forum, :list?
    @membership = @forum.memberships.find_by profile_id: params[:id]
    authorize @membership, :destroy?

    if @membership.destroy
      respond_to do |f|
        f.html { redirect_to preferred_forum }
        f.js { render }
      end
    else
      respond_to do |f|
        f.html { redirect_to preferred_forum }
        f.js { render json: {notifications: [{type: 'error', message: '_niet gelukt_'}]} }
      end
    end
  end

private
  def permit_params
    params.permit :forum_id, :role, :r
  end
end
