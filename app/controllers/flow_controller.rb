class FlowController < AuthorizedController
  include NestedResourceHelper

  def show
    authorize authenticated_resource!, :show?
    @activities = policy_scope(authenticated_resource!.flow)

    respond_to do |format|
      format.json do
        render json: @activities,
               include: %w(recipient owner)
      end
    end
  end

  private

  def authenticated_resource!
    @_authenticated_resource ||= get_parent_resource
  end
end
