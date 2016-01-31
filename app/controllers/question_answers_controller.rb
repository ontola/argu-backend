class QuestionAnswersController < ApplicationController

  # GET /question_answers/new
  def new
    @question = Question.find(permit_params[:question_id])
    authorize @question, :show?
    @motions = @question.forum.motions
    @forum = @question.forum
    @question_answer = QuestionAnswer.new question: @question, motion: Motion.new
    authorize @question_answer, :new?
    current_context @question_answer
  end

  # POST /question_answers
  # POST /question_answers.json
  def create
    @question = Question.find(permit_params[:question_id])
    @motion = Motion.find(permit_params[:motion_id])
    @forum = @question.forum

    @question_answer = QuestionAnswer.new(question: @question, motion: @motion)
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

  private

  def permit_params
    params.require(:question_answer).permit(*policy(@question_answer || QuestionAnswer).permitted_attributes)
  end
end
