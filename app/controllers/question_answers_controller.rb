# frozen_string_literal: true
class QuestionAnswersController < ApplicationController
  helper_method :collect_banners

  # GET /question_answers/new
  def new
    @forum = new_resource_from_params.question.forum
    @motions = new_resource_from_params.question.forum.motions
    authorize new_resource_from_params.question, :show?
    authorize new_resource_from_params, :new?

    render locals: {
      question_answer: new_resource_from_params,
      question: new_resource_from_params.question,
      forum: @forum
    }
  end

  # POST /question_answers
  # POST /question_answers.json
  def create
    @forum = new_resource_from_params.question.forum
    authorize new_resource_from_params, :create?

    respond_to do |format|
      if new_resource_from_params.save
        format.html { redirect_to new_resource_from_params.question, notice: 'Motion was successfully coupled.' }
        format.json { render :show, status: :created, location: new_resource_from_params }
      else
        format.html do
          render :new,
                 locals: {
                   question_answer: new_resource_from_params,
                   question: new_resource_from_params.question,
                   forum: @forum
                 }
        end
        format.json { render json: new_resource_from_params.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def collect_banners
  end

  def new_resource_from_params
    @resource ||= QuestionAnswer.new(
      question: Question.find(params.require(:question_answer)[:question_id]),
      motion: Motion.find_by(id: params.require(:question_answer)[:motion_id]),
      options: service_options
    )
  end

  def service_options(options = {})
    {
      creator: current_profile,
      publisher: current_user
    }.merge(options)
  end
end
