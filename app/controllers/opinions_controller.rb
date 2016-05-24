class OpinionsController < AuthorizedController
  include NestedResourceHelper

  def create
    hui
    create_service.subscribe(ActivityListener.new(creator: current_profile,
                                                  publisher: current_user))
    create_service.on(:create_opinion_successful) do |opinion|
      respond_to do |format|
        format.html { redirect_to opinion }
        format.json { render json: opinion, status: 201, location: opinion }
      end
    end
    create_service.on(:create_opinion_failed) do |opinion|
      respond_to do |format|
        format.html { render :new, locals: {project: opinion} }
        format.json { render json: opinion.errors, status: 422 }
      end
    end
    create_service.commit
  end

  private

  def create_service
    ergger
    @create_service ||= CreateOpinion.new(
      Opinion.new,
      resource_new_params.merge(permit_params.merge(publisher: current_user,
                                                    creator: current_profile)))
  end

  def permit_params
    params.require(:opinion).permit(*policy(@opinion || Opinion).permitted_attributes)
  end

  def resource_new_params
    super.merge(motion_id: params[:motion_id])
  end
end
