class QuestionsController < ApplicationController

  def show
    @question = Question.find(params[:id])
    authorize @question
    @forum = @question.forum
    current_context @question
    #@voted = Vote.where(voteable: @question, voter: current_user).last.try(:for) unless current_user.blank?
    @motions = @question.motions

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

    @question = @forum.questions.new permit_params
    #@question.creator = current_user
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

  # PUT /motions/1
  # PUT /motions/1.json
  def update
    @question = Question.find_by_id params[:id]
    authorize @question
    respond_to do |format|
      if @question.update_attributes(permit_params)
        format.html { redirect_to @question, notice: 'Motion was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render 'form' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def permit_params
    params.require(:question).permit(:id, :title, :content, :tag_list, :forum_id)
  end
end
