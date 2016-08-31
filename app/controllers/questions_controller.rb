class QuestionsController < AuthorizedController
  include NestedResourceHelper, MotionsHelper, StateGenerators::ModelConverters

  def show
    scope = authenticated_resource!
                .motions
                .includes(:default_cover_photo, :edge, :votes, :top_arguments_con, :top_arguments_pro, :forum,
                          creator: {default_profile_photo: [], profileable: [:shortname]})
                .trashed(show_trashed?)
                .order(votes_pro_count: :desc)

    if current_user.present?
      @user_votes = Vote.where(voteable: scope, voter: current_profile).eager_load!
      vvotes = @user_votes.map { |vote| vote_item(vote) }
      add_to_state 'votes',
                   records: vvotes
    end

    @motions = policy_scope(scope)
                 .page(show_params[:page])

    mmotions = @motions.map { |motion| motion_item(motion) }
    add_to_state 'motions',
                 records: mmotions

    respond_to do |format|
      format.html { render locals: {question: authenticated_resource!}} # show.html.erb
      format.widget { render authenticated_resource! }
      format.json # show.json.jbuilder
    end
  end

  def new
    respond_to do |format|
      format.js { render js: "window.location = #{request.url.to_json}" }
      format.html { render 'form', locals: {question: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  # GET /questions/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form', locals: {question: authenticated_resource!} }
    end
  end

  def create
    create_service.on(:create_question_successful) do |question|
      respond_to do |format|
        format.html { redirect_to question, notice: t('type_save_success', type: question_type) }
        format.json { render json: question, status: :created, location: question }
      end
    end
    create_service.on(:create_question_failed) do |question|
      respond_to do |format|
        format.html { render 'form', locals: {question: question} }
        format.json { render json: question.errors, status: :unprocessable_entity }
      end
    end
    create_service.commit
  end

  # PUT /questions/1
  # PUT /questions/1.json
  def update
    update_service.on(:update_question_successful) do |question|
      respond_to do |format|
        format.html { redirect_to question, notice: t('type_save_success', type: question_type) }
        format.json { head :no_content }
      end
    end
    update_service.on(:update_question_failed) do |question|
      respond_to do |format|
        format.html { render 'form', locals: {question: question} }
        format.json { render json: question.errors, status: :unprocessable_entity }
      end
    end
    update_service.commit
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    destroy_service.on(:destroy_question_successful) do |question|
      respond_to do |format|
        format.html { redirect_to question.forum, notice: t('type_destroy_success', type: t('questions.type')) }
        format.json { head :no_content }
      end
    end
    destroy_service.on(:destroy_question_failed) do |question|
      respond_to do |format|
        format.html { redirect_to question, notice: t('errors.general') }
        format.json { render json: question.errors, status: :unprocessable_entity }
      end
    end
    destroy_service.commit
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def trash
    trash_service.on(:trash_question_successful) do |question|
      respond_to do |format|
        format.html { redirect_to question.forum, notice: t('type_trash_success', type: t('questions.type')) }
        format.json { head :no_content }
      end
    end
    trash_service.on(:trash_question_failed) do |question|
      respond_to do |format|
        format.html { redirect_to question, notice: t('errors.general') }
        format.json { render json: question.errors, status: :unprocessable_entity }
      end
    end
    trash_service.commit
  end

  # PUT /arguments/1/untrash
  # PUT /arguments/1/untrash.json
  def untrash
    untrash_service.on(:untrash_question_successful) do |question|
      respond_to do |format|
        format.html { redirect_to question, notice: t('type_untrash_success', type: t('questions.type')) }
        format.json { head :no_content }
      end
    end
    untrash_service.on(:untrash_question_failed) do |question|
      respond_to do |format|
        format.html { redirect_to question, notice: t('errors.general') }
        format.json { render json: question.errors, status: :unprocessable_entity }
      end
    end
    untrash_service.commit
  end

  # GET /motions/1/move
  def move
    @question = Question.find params[:question_id]
    authorize @question, :move?

    respond_to do |format|
      format.html { render locals: {resource: @question} }
      format.js { render }
    end
  end

  def move!
    @question = Question.find(params[:question_id])
    authorize @question, :move?
    @forum = Forum.find permit_params[:forum_id]
    authorize @forum, :update?
    moved = nil
    @question.with_lock do
      moved = @question.move_to @forum, permit_params[:include_motions] == '1'
    end
    if moved
      redirect_to question_url(@question)
    else
      redirect_to edit_question_url @question
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

  def authenticated_resource!
    if (%w(convert convert! move move!) & [params[:action]]).present?
      Question.find(params[:question_id])
    else
      super
    end
  end

  def permit_params
    params.require(:question).permit(*policy(@question || Question).permitted_attributes)
  end

  def show_params
    params.permit(:page)
  end
end
