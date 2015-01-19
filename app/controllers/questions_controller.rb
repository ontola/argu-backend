class QuestionsController < ApplicationController

  def show
    @question = Question.find(params[:id])
    authorize @question
    @forum = @question.forum
    current_context @question
    #@voted = Vote.where(voteable: @question, voter: current_user).last.try(:for) unless current_user.blank?
    @motions = policy_scope(@question.motions.trashed(show_trashed?))

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @question }
      format.json # show.json.jbuilder
    end
  end

  def new
    @forum = Forum.friendly.find params[:forum_id]
    @question = Question.new params[:question]
    @question.forum= @forum
    authorize @question
    current_context @question
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @question }
    end
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find_by_id(params[:id])
    authorize @question
    current_context @question
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  def create
    @forum = Forum.friendly.find params[:forum_id]
    authorize @forum, :add_question?

    @question = @forum.questions.new
    @question.attributes= permit_params
    @question.creator = current_profile
    authorize @question

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: t('type_save_success', type: t('motions.type')) }
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
    @question = Question.includes(:taggings).find_by_id(params[:id])
    authorize @question

    @question.reload if process_cover_photo @question, permit_params
    respond_to do |format|
      if @question.update(permit_params)
        format.html { redirect_to @question, notice: 'Motion was successfully updated.' }
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
    @question = Question.find_by_id params[:id]
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

private
  def permit_params
    params.require(:question).permit(*policy(@question || Question).permitted_attributes)
  end
end
