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
      errors << {title: 'Query parameter `q` not present'} unless params[:q].present?
      errors << {title: 'Type parameter `thing` not present'} unless params[:thing].present?
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
    create_service.subscribe(ActivityListener.new(creator: current_profile,
                                                  publisher: current_user))
    create_service.on(:create_motion_successful) do |motion|
      respond_to do |format|
        first = current_profile.motions.count == 1 || nil
        format.html { redirect_to motion_path(motion, start_motion_tour: first), notice: t('type_save_success', type: motion_type) }
        format.json { render json: motion, status: :created, location: motion }
      end
    end
    create_service.on(:create_motion_failed) do |motion|
      respond_to do |format|
        format.html { render 'form', locals: {motion: motion} }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    create_service.commit
  end

  # PUT /motions/1
  # PUT /motions/1.json
  def update
    update_service.resource.reload if process_cover_photo update_service.resource, permit_params
    update_service.subscribe(ActivityListener.new(creator: current_profile,
                                                  publisher: current_user))
    update_service.on(:update_motion_successful) do |motion|
      respond_to do |format|
        if params[:motion].present? && params[:motion][:tag_id].present? && motion.tags.reject { |a,b| a.motion == b }.first.present?
          format.html { redirect_to tag_motions_url(Tag.find_by_id(motion.tag_id).name)}
          format.json { head :no_content }
        else
          format.html { redirect_to motion, notice: t('type_save_success', type: motion_type) }
          format.json { head :no_content }
        end
      end
    end
    update_service.on(:update_motion_failed) do |motion|
      respond_to do |format|
        format.html { render 'form', locals: {motion: motion} }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    update_service.commit
  end

  # DELETE /motions/1?destroy=true
  # DELETE /motions/1.json?destroy=true
  def destroy
    destroy_service.subscribe(ActivityListener.new(creator: current_profile,
                                                   publisher: current_user))
    destroy_service.on(:destroy_motion_successful) do |motion|
      parent = motion.get_parent.model.try(:first) || motion.get_parent.model
      respond_to do |format|
        format.html { redirect_to parent, notice: t('type_destroy_success', type: t('motions.type')) }
        format.json { head :no_content }
      end
    end
    destroy_service.on(:destroy_motion_failed) do |motion|
      respond_to do |format|
        format.html { redirect_to motion, notice: t('errors.general') }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    destroy_service.commit
  end

  # DELETE /motions/1
  # DELETE /motions/1.json
  def trash
    trash_service.subscribe(ActivityListener.new(creator: current_profile,
                                                 publisher: current_user))
    trash_service.on(:trash_motion_successful) do |motion|
      parent = motion.get_parent.model.try(:first) || motion.get_parent.model
      respond_to do |format|
        format.html { redirect_to parent, notice: t('type_trash_success', type: t('motions.type')) }
        format.json { head :no_content }
      end
    end
    trash_service.on(:trash_motion_failed) do |motion|
      respond_to do |format|
        format.html { redirect_to motion, notice: t('errors.general') }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    trash_service.commit
  end

  # PUT /motions/1/untrash
  # PUT /motions/1/untrash.json
  def untrash
    untrash_service.subscribe(ActivityListener.new(creator: current_profile,
                                                   publisher: current_user))
    untrash_service.on(:untrash_motion_successful) do |motion|
      parent = motion.get_parent.model.try(:first) || motion.get_parent.model
      respond_to do |format|
        format.html { redirect_to motion, notice: t('type_untrash_success', type: t('motions.type')) }
        format.json { head :no_content }
      end
    end
    untrash_service.on(:untrash_motion_failed) do |motion|
      respond_to do |format|
        format.html { redirect_to motion, notice: t('errors.general') }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    untrash_service.commit
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

  def authorize_action
    if params[:action] == 'create'
      action = create_service.resource.question.presence ? :create? : :create_without_question?
      authorize create_service.resource, action
    else
      super
    end
  end

  def authorize_show
    @motion = Motion.includes(:arguments).find(params[:id])
    authorize @motion, :show?
  end

  def create_service
    @create_service ||= CreateMotion.new(
      Motion.new,
      permit_params.merge(resource_new_params.merge(publisher: current_user,
                                                    creator: current_profile)))
  end

  def destroy_service
    @destroy_service ||= DestroyMotion.new(resource_by_id)
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
      super.merge(project: get_parent_resource.project)
    else
      super
    end
  end

  def trash_service
    @trash_service ||= TrashMotion.new(resource_by_id)
  end

  def untrash_service
    @untrash_service ||= UntrashMotion.new(resource_by_id)
  end

  def update_service
    @update_service ||= UpdateMotion.new(
      resource_by_id,
      permit_params)
  end
end
