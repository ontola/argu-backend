# frozen_string_literal: true

class QuestionAnswersController < ParentableController
  private

  def current_forum
    question&.forum
  end

  def collect_banners; end

  def parent_resource
    authenticated_resource&.question
  end

  def message_success(resource, action)
    return super unless action == :create
    'Motion was successfully coupled.'
  end

  def motion
    Motion.find_by(id: params.require(:question_answer)[:motion_id])
  end

  def resource_new_params
    {
      question: question!,
      motion: motion,
      options: service_options
    }
  end

  def question!
    question || raise(ActiveRecord::RecordNotFound)
  end

  def question
    Question.find_by(id: params.require(:question_answer)[:question_id])
  end

  def redirect_model_success(resource)
    resource.question.iri(only_path: true).to_s
  end

  def service_options(options = {})
    {
      creator: current_actor.actor,
      publisher: current_user
    }.merge(options)
  end
end
