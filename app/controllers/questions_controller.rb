class QuestionsController < ApplicationController

  def show
    @question = Question.find(params[:id])
    authorize @question
    @forum = current_forum
    current_context @question
    @motions = policy_scope(@question.motions.trashed(show_trashed?)).order(updated_at: :desc)

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @question }
      format.json # show.json.jbuilder
    end
  end

  def new
    @forum = current_forum
    @question = Question.new params[:question]
    @question.forum= @forum
    if current_profile.blank?
      authorize @question, :show?
      render_register_modal(nil)
    else
      authorize @question
      current_context @question
      respond_to do |format|
        if !current_profile.member_of? @question.forum
          format.js { render partial: 'forums/join', layout: false, locals: { forum: @question.forum, r: request.fullpath } }
          format.html { render template: 'forums/join', locals: { forum: @question.forum, r: request.fullpath } }
        else
          format.js { render js: "window.location = #{request.url.to_json}" }
          format.html { render 'form' }
          format.json { render json: @question }
        end
      end
    end
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
    authorize @question
    @forum = current_forum
    current_context @question
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  def create
    @forum = current_forum
    authorize @forum, :add_question?

    @question = @forum.questions.new
    @question.attributes = permit_params
    @question.creator = current_profile
    authorize @question

    respond_to do |format|
      if @question.save
        create_activity @question, action: :create, recipient: @question.forum, owner: current_profile, forum_id: @forum.id
        format.html { redirect_to @question, notice: t('type_save_success', type: question_type) }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render 'form' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.json
  def update
    @question = Question.find(params[:id])
    authorize @question
    @forum = current_forum

    @question.reload if process_cover_photo @question, permit_params
    respond_to do |format|
      if @question.update(permit_params)
        format.html { redirect_to @question, notice: t('type_save_success', type: question_type) }
        format.json { head :no_content }
      else
        format.html { render 'form' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
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
    @forum = current_forum
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

private
  def self.forum_for(url_options)
    Question.find_by(url_options[:question_id] || url_options[:id]).try(:forum)
  end

  def permit_params
    params.require(:question).permit(*policy(@question || Question).permitted_attributes)
  end
end
