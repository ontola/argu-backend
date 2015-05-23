class MotionsController < ApplicationController
  before_action :get_context, only: [:new, :create]

  # GET /motions/1
  # GET /motions/1.json
  def show
    @motion = Motion.includes(:arguments, :opinions).find(params[:id])
    @forum = @motion.forum
    authorize @motion
    current_context @motion
    @arguments = Argument.ordered policy_scope(@motion.arguments.trashed(show_trashed?))
    @group_responses = Group.ordered_with_meta @motion.group_responses, @forum.groups, current_profile, @motion
    @vote = Vote.where(voteable: @motion, voter: current_profile).last unless current_user.blank?
    @vote ||= Vote.new

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @motion }
      format.json # show.json.jbuilder
    end
  end

  # GET /motions/new
  # GET /motions/new.json
  def new
    get_context
    @motion = @forum.motions.new params[:motion]
    if params[:question_id]
      question = Question.find(params[:question_id])
      @motion.questions << question if @motion.forum_id == question.forum_id
    end
    if current_profile.blank?
      authorize @motion, :show?
      render_register_modal(nil)
    else
      authorize @motion, @motion.questions.presence ? :create? : :create_without_question?
      current_context @motion
      respond_to do |format|
        if current_profile.member_of? @motion.forum
          format.js { render js: "window.location = #{request.url.to_json}" }
          format.html { render 'form' }
          format.json { render json: @motion }
        else
          format.js { render partial: 'forums/join', layout: false, locals: { forum: @motion.forum, r: request.fullpath} }
          format.html { render template: 'forums/join', locals: { forum: @motion.forum, r: request.fullpath, no_close: true } }
        end
      end
    end
  end

  # GET /motions/1/edit
  def edit
    @motion = Motion.find_by_id(params[:id])
    @forum = @motion.forum
    authorize @motion
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /motions
  # POST /motions.json
  def create
    get_context
    authorize @forum, :add_motion?

    @motion = @forum.motions.new
    @motion.attributes= permit_params
    @question_id = params[:question_id] || params[:motion][:question_id]
    @motion.creator = current_profile
    @motion.questions << @question if @question.present?

    authorize @motion, @motion.questions.presence ? :create? : :create_without_question?

    respond_to do |format|
      if @motion.save
        create_activity @motion, action: :create, recipient: (@question.presence || @motion.forum), owner: current_profile, forum_id: @motion.forum.id
        format.html { redirect_to @motion, notice: t('type_save_success', type: motions_type) }
        format.json { render json: @motion, status: :created, location: @motion }
      else
        format.html { render 'form' }
        format.json { render json: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motions/1
  # PUT /motions/1.json
  def update
    @motion = Motion.find_by_id params[:id]
    @creator = @motion.creator
    @forum = @motion.forum
    authorize @motion

    @motion.reload if process_cover_photo @motion, permit_params
    respond_to do |format|
      if @motion.update(permit_params)
        if params[:motion].present? && params[:motion][:tag_id].present? && @motion.tags.reject { |a,b| a.motion==b }.first.present?
          format.html { redirect_to tag_motions_url(Tag.find_by_id(@motion.tag_id).name)}
          format.json { head :no_content }
        else
          format.html { redirect_to @motion, notice: t('type_save_success', type: motion_type) }
          format.json { head :no_content }
        end
      else
        format.html { render 'form' }
        format.json { render json: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /motions/1
  # DELETE /motions/1.json
  def destroy
    @motion = Motion.find_by_id params[:id]
    if params[:destroy].to_s == 'true'
      authorize @motion, :destroy?
      @motion.destroy
    else
      authorize @motion, :trash?
      @motion.trash
    end

    parent = @motion.get_parent.model.try(:first) || @motion.get_parent.model
    respond_to do |format|
      format.html { redirect_to parent }
      format.json { head :no_content }
    end
  end

  # GET /motions/1/convert
  def convert
    @motion = Motion.find_by_id params[:motion_id]
    authorize @motion, :move?

    respond_to do |format|
      format.html { render locals: {resource: @motion} }
      format.js { render }
    end
  end

  def convert!
    @motion = Motion.find_by_id(params[:motion_id]).lock!
    authorize @motion, :move?
    authorize @motion.forum, :update?

    @result = @motion.convert_to convertible_param_to_model(permit_params[:f_convert])
    if @result
      redirect_to @result[:new]
    else
      redirect_to edit_motion_url @motion
    end
  end

  # GET /motions/1/move
  def move
    @motion = Motion.find_by_id params[:motion_id]
    authorize @motion, :move?

    respond_to do |format|
      format.html { render locals: {resource: @motion} }
      format.js { render }
    end
  end

  def move!
    @motion = Motion.find_by_id(params[:motion_id]).lock!
    authorize @motion, :move?
    @forum = Forum.find_by_id permit_params[:forum_id]
    authorize @forum, :update?

    if @motion.move_to @forum
      redirect_to @motion
    else
      redirect_to edit_motion_url @motion
    end
  end

private
  def permit_params
    params.require(:motion).permit(*policy(@motion || Motion).permitted_attributes)
  end

  def get_context
    if params[:question_id].present? || defined?(params[:motion][:question_id]) && params[:motion][:question_id].present?
      @question = Question.find(params[:question_id] || params[:motion][:question_id])
    end
    @forum = Forum.find_via_shortname(params[:forum_id]) if params[:forum_id].present?
  end
end
