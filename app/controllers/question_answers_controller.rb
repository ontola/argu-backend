# frozen_string_literal: true
class QuestionAnswersController < AuthorizedController
  helper_method :collect_banners

  private

  def collect_banners; end

  def message_success(resource, action)
    return super unless action == :create
    'Motion was successfully coupled.'
  end

  def new_resource_from_params
    @resource ||= QuestionAnswer.new(
      question: Question.find(params.require(:question_answer)[:question_id]),
      motion: Motion.find_by(id: params.require(:question_answer)[:motion_id]),
      options: service_options
    )
  end

  def redirect_model_success(resource)
    resource.question
  end

  def service_options(options = {})
    {
      creator: current_profile,
      publisher: current_user
    }.merge(options)
  end
end
