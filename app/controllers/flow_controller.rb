class FlowController < AuthenticatedController
  include NestedResourceHelper

  def show
    activities = Activity.arel_table
    resource = authenticated_resource!
    @activities = policy_scope(Activity.where(
      activities[:trackable_id].eq(resource.id).and(
        activities[:trackable_type].eq(resource.model_name.to_s))
        .or(activities[:recipient_id].eq(resource).and(
          activities[:recipient_type].eq(resource.model_name.to_s)))))

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
