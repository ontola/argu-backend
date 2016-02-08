class QuestionAnswer
  extend ActiveModel::Naming
  include ActiveModel::Validations

  validates_presence_of :question, :motion

  attr_accessor :question, :motion

  def initialize(question:, motion: nil)
    @question, @motion = question, motion
  end

  def persisted?
    false
  end

  def save
    if same_forum
      Question.transaction do
        @motion.update question_id: @question.id
      end
    end
  end

  def same_forum
    if @question.forum.present? && @motion.forum.present?
      @question.forum.id == @motion.forum.id
    else
      false
    end
  end

  def to_key
    []
  end

  def to_model
    self
  end
end
