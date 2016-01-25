class QuestionsController < AuthorizedController

  def show
    @motions = policy_scope(authenticated_resource!
                              .motions
                              .trashed(show_trashed?)
                              .order(updated_at: :desc))

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
    authorize authenticated_context, :add_question?
    @cq = CreateQuestion.new current_profile,
                          permit_params.merge({
                              forum: authenticated_context,
                              publisher: current_user
                          })
    authorize @cq.resource, :create?
    @cq.subscribe(ActivityListener.new)
    @cq.on(:create_question_successful) do |question|
      respond_to do |format|
        format.html { redirect_to question, notice: t('type_save_success', type: question_type) }
        format.json { render json: question, status: :created, location: question }
      end
    end
    @cq.on(:create_question_failed) do |question|
      respond_to do |format|
        format.html { render 'form', locals: {question: question} }
        format.json { render json: question.errors, status: :unprocessable_entity }
      end
    end
    @cq.commit
  end

  # PUT /questions/1
  # PUT /questions/1.json
  def update
    authenticated_resource!.reload if process_cover_photo authenticated_resource!, permit_params
    respond_to do |format|
      if authenticated_resource!.update(permit_params)
        format.html { redirect_to authenticated_resource!, notice: t('type_save_success', type: question_type) }
        format.json { head :no_content }
      else
        format.html { render 'form', locals: {question: authenticated_resource!} }
        format.json { render json: authenticated_resource!.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question = Question.find params[:id]
    if params[:destroy].to_s == 'true'
      authorize @question
      @question.destroy
    else
      authorize @question, :trash?
      @question.trash
    end

    respond_to do |format|
      format.html { redirect_to @question.forum }
      format.json { head :no_content }
    end
  end

  # GET /motions/1/convert
  def convert
    @question = Question.find params[:question_id]
    authorize @question, :move?

    respond_to do |format|
      format.html { render locals: {resource: @question} }
      format.js { render }
    end
  end

  def convert!
    @question = Question.find(params[:question_id])
    authorize @question, :move?
    @forum = Forum.find_by_id permit_params[:forum_id]
    authorize @question.forum, :update?
    @question.with_lock do
      @result = @question.convert_to convertible_param_to_model(permit_params[:f_convert])
    end
    if @result
      redirect_to polymorphic_url(@result[:new])
    else
      redirect_to edit_question_url @question
    end
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
end
