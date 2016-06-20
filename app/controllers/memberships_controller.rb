class MembershipsController < AuthorizedController
  skip_before_action :check_if_member, only: %i(create)

  def create
    @membership = Membership.new resource_new_params
    authorize @membership, :create?

    created = params[:redirect] == 'false' ? 201 : nil
    if @membership.save
      if created
        head 201
      else
        redirect_to params[:r].presence || @membership.forum
      end
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
    @forum = Forum.find_via_shortname(params[:forum_id])
    authorize @forum, :list?
    @membership = current_profile.memberships.find params[:id]
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

  def authenticated_resource
    if params[:action] == 'create'
      authenticated_context or super
    else
      super
    end
  end

  def destroy_service
    Struct.new('DestroyMembership', :resource).new
  end

  def create_service
    Struct.new('CreateMembership', :resource).new
  end

  def permit_params
    params.permit :forum_id, :role, :r
  end

  def redirect_url
    params[:action] == 'create' ? forum_path(params[:forum_id]) : super
  end

  def resource_new_params
    {
      profile: current_profile,
      forum: resource_tenant,
      role: (permit_params[:role] || Membership.roles[:member])
    }
  end
end
