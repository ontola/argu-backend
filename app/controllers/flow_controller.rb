class FlowController < AuthenticatedController
  include NestedResourceHelper

  def show
    resource = authenticated_resource!
    @activities = policy_scope(resource.flow)

    respond_to do |format|
      format.json do
        render json: @activities,
               include: %w(recipient owner)
      end
    end
  end

  private

  def authenticated_resource!
    get_parent_resource
  end

end
