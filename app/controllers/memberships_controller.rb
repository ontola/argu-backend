class MembershipsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_member, only: %i(create)

  def create
    create_service.on(:create_membership_successful) do |membership|
      if params[:redirect] == 'false'
        head 201
      else
        redirect_to redirect_param.presence || membership.forum
      end
    end
    create_service.on(:create_membership_failed) do
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
    end
    create_service.commit
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
    destroy_service.on(:destroy_membership_successful) do
      respond_to do |f|
        f.html { redirect_to preferred_forum }
        f.js { render }
      end
    end
    destroy_service.on(:destroy_membership_failed) do
      respond_to do |f|
        f.html { redirect_to preferred_forum }
        f.js { render json: {notifications: [{type: 'error', message: '_niet gelukt_'}]} }
      end
    end
    destroy_service.commit
  end

  private

  def destroy_service
    @destroy_service ||= DestroyMembership.new(resource_by_id, options: service_options)
  end

  def permit_params
    params.permit :forum_id, :role
  end

  def redirect_param
    params.permit(:r)[:r]
  end

  def redirect_url
    params[:action] == 'create' ? forum_path(params[:forum_id]) : super
  end

  def resource_new_params
    {
      profile: current_profile,
      role: (permit_params[:role] || Membership.roles[:member])
    }
  end
end
