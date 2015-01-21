class MembershipsController < ApplicationController
  #responds_to :js

  def create
    forum = Forum.friendly.find params[:forum_id]
    @membership = Membership.new profile: current_profile, forum: forum, role: (permit_params[:role] || Membership.roles[:member])
    authorize @membership, :create?

    if @membership.save
      redirect_to params[:r].presence || @membership.forum
    else
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
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
    @membership = Forum.find(params[:forum_id]).memberships.find params[:id]
    authorize @membership
    if @membership.destroy
      respond_to do |f|
        f.js { render }
      end
    else
      respond_to do |f|
        f.js { render json: {notifications: [{type: 'error', message: '_niet gelukt_'}]} }
      end
    end
  end

private
  def permit_params
    params.permit :forum_id, :role, :r
  end
end
