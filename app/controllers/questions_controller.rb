# frozen_string_literal: true
class QuestionsController < EdgeTreeController
  include EdgeTree::Move, MenuHelper, VotesHelper
  skip_before_action :check_if_registered, only: :index

  def show
    @motions = policy_scope(authenticated_resource.motions)
                 .joins(:edge, :default_vote_event_edge)
                 .includes(:default_cover_photo, :edge, :votes,
                           creator: {default_profile_photo: []})
                 .order("cast(default_vote_event_edges_motions.children_counts -> 'votes_pro' AS int) DESC NULLS LAST")
                 .page(show_params[:page])
    preload_user_votes(@motions.ids) unless current_user.guest?

    init_resource_actions(authenticated_resource)

    respond_to do |format|
      format.html { render locals: {question: authenticated_resource} } # show.html.erb
      format.widget { render authenticated_resource }
      format.json # show.json.jbuilder
      format.json_api do
        render json: authenticated_resource,
               include: [
                 attachment_collection: INC_NESTED_COLLECTION,
                 motion_collection: INC_NESTED_COLLECTION
               ]
      end
    end
  end

  def forum_for(url_options)
    question_id = url_options[:question_id] || url_options[:id]
    if question_id.presence
      Question.find_by(id: question_id).try(:forum)
    elsif url_options[:forum_id].present?
      Forum.find_via_shortname_nil url_options[:forum_id]
    end
  end

  private

  def authenticated_resource
    if (%w(convert convert! shift move) & [params[:action]]).present?
      @resource ||= Question.find(params[:question_id])
    else
      super
    end
  end

  def move_options
    permit_params[:include_motions] == '1'
  end

  def show_params
    params.permit(:page)
  end
end
