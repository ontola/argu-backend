class MotionsController < AuthorizedController
  include NestedResourceHelper
  before_action :get_context, only: [:index, :new, :create]
  skip_before_action :authorize_action, :check_if_member, only: :index

  def index
    if params[:q].present? && params[:thing].present?
      @motions = policy_scope(Motion).search(params[:q])
      if @motions.present?
        render json: @motions
      else
        render json: {data: []}
      end
    else
      skip_verify_policy_scoped(true)
      errors = []
      errors << { title: 'Query parameter `q` not present' } unless params[:q].present?
      errors << { title: 'Type parameter `thing` not present' } unless params[:thing].present?
      render status: 400,
             json: {errors: errors}
    end
  end

  # GET /motions/1
  # GET /motions/1.json
  def show
    @arguments = Argument.ordered policy_scope(@motion.arguments.trashed(show_trashed?).includes(:votes))
    discussion_responses = @motion.group_responses.where(group_id: authenticated_context.groups.discussion)
    @group_responses = Group.ordered_with_meta discussion_responses, authenticated_context.groups.discussion, current_profile, @motion
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
    authorize authenticated_resource!, authenticated_resource!.question.presence ? :new? : :new_without_question?
    respond_to do |format|
      format.js { render js: "window.location = #{request.url.to_json}" }
      format.html { render 'form', locals: {motion: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  # GET /motions/1/edit
  def edit
    @motion = Motion.find_by_id(params[:id])
    authorize @motion
    respond_to do |format|
      format.html { render 'form', locals: {motion: @motion} }
    end
  end

  # POST /motions
  # POST /motions.json
  def create
    @cm = CreateMotion.new current_profile,
                           permit_params.merge(resource_new_params)
    action = @cm.resource.question.presence ? :create? : :create_without_question?
    authorize @cm.resource, action
    @cm.subscribe(ActivityListener.new)
    @cm.on(:create_motion_successful) do |motion|
      respond_to do |format|
        first = current_profile.motions.count == 1 || nil
        format.html { redirect_to motion_path(motion, start_motion_tour: first), notice: t('type_save_success', type: motion_type) }
        format.json { render json: motion, status: :created, location: motion }
      end
    end
    @cm.on(:create_motion_failed) do |motion|
      respond_to do |format|
        format.html { render 'form', locals: {motion: @cm.resource} }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    @cm.commit
  end

  # PUT /motions/1
  # PUT /motions/1.json
  def update
    @motion = Motion.find params[:id]
    @creator = @motion.creator
    authorize @motion

    @motion.reload if process_cover_photo @motion, permit_params
    respond_to do |format|
      if @motion.update(permit_params)
        if params[:motion].present? && params[:motion][:tag_id].present? && @motion.tags.reject { |a,b| a.motion == b }.first.present?
          format.html { redirect_to tag_motions_url(Tag.find_by_id(@motion.tag_id).name)}
          format.json { head :no_content }
        else
          format.html { redirect_to @motion, notice: t('type_save_success', type: motion_type) }
          format.json { head :no_content }
        end
      else
        format.html { render 'form', locals: {motion: @motion} }
        format.json { render json: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /motions/1
  # DELETE /motions/1.json
  def destroy
    if params[:destroy].to_s == 'true'
      flash[:notice] = t('type_save_success',
                         type: t('motions.type'))
      authenticated_resource!.destroy
    else
      flash[:notice] = t('type_save_success',
                         type: t('motions.type'))
      authenticated_resource!.trash
    end

    parent = authenticated_resource!.get_parent.model.try(:first) || authenticated_resource!.get_parent.model
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
    @motion = Motion.find(params[:motion_id]).lock!
    authorize @motion, :move?
    authorize @motion.forum, :update?

    @motion.with_lock do
      @result = @motion.convert_to convertible_param_to_model(permit_params[:f_convert])
    end
    if @result
      redirect_to polymorphic_url(@result[:new])
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
    @motion = Motion.find(params[:motion_id])
    authorize @motion, :move?
    @forum = Forum.find permit_params[:forum_id]
    authorize @forum, :update?
    moved = false
    @motion.with_lock do
      moved = @motion.move_to @forum
    end
    if moved
      redirect_to motion_url(@motion)
    else
      redirect_to edit_motion_url @motion
    end
  end

  def forum_for(url_options)
    motion_id = url_options[:motion_id] || url_options[:id]
    if motion_id.presence
      Motion.find_by(id: motion_id).try(:forum)
    elsif url_options[:forum_id].present?
      Forum.find_via_shortname_nil url_options[:forum_id]
    end
  end

  private

  def authenticated_resource!
    if (%w(convert convert! move move!) & [params[:action]]).present?
      Motion.find(params[:motion_id])
    else
      super
    end
  end

  def authorize_show
    @motion = Motion.includes(:arguments).find(params[:id])
    authorize @motion, :show?
  end

  def get_context
    if params[:question_id].present? || defined?(params[:motion][:question_id]) && params[:motion][:question_id].present?
      @question = Question.find(params[:question_id] || params[:motion][:question_id])
    end
  end

  def permit_params
    if params[:motion].present?
      params.require(:motion).permit(*policy(@motion || Motion).permitted_attributes)
    end
  end

  def resource_new_params
    if get_parent_resource.try(:project).present?
      super.merge({
        project: get_parent_resource.project
      })
    else
      super
    end
  end
end
