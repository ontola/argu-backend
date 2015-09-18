class QuestionAnswersController < ApplicationController
  before_action :set_question_answer, only: [:show, :edit, :update, :destroy]

  # GET /question_answers/new
  def new
    @question = Question.find(params[:question_id])
    authorize @question, :show?
    @motions = @question.forum.motions
    @forum = @question.forum
    @question_answer = QuestionAnswer.new question: @question
    authorize @question_answer, :new?
    current_context @question_answer
  end

  # POST /question_answers
  # POST /question_answers.json
  def create
    @question = Question.find(params[:question_id])
    @forum = @question.forum
    @question_answer = @question.question_answers.new(permit_params)
    @question_answer.creator = current_user.profile
    authorize @question_answer, :create?

    respond_to do |format|
      if @question_answer.save
        format.html { redirect_to @question, notice: 'Motion was successfully coupled.' }
        format.json { render :show, status: :created, location: @question_answer }
      else
        format.html { render :new }
        format.json { render json: @question_answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_answers/1
  # DELETE /question_answers/1.json
  def destroy
    @forum = @question_answer.question.forum
    authorize @question_answer, :destroy?
    @question_answer.destroy

    respond_to do |format|
      format.html { redirect_to question_url(@question_answer.question) }
      format.js { redirect_to question_url(@question_answer.question) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_answer
      @question_answer = QuestionAnswer.find(params[:id])
    end

    def permit_params
      params.require(:question_answer).permit(*policy(@question_answer || QuestionAnswer).permitted_attributes)
    end
end
