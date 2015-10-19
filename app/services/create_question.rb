
class CreateQuestion < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @question = profile.questions.new(attributes)
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @question.publisher = profile.profileable
    end
  end

  def resource
    @question
  end

  def commit
    Question.transaction do
      @question.save!
      @question.publisher.follow(@question)
      publish(:create_question_successful, @question)
    end
  rescue ActiveRecord::RecordInvalid
    publish(:create_question_failed, @question)
  end

end
