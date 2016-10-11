# frozen_string_literal: true
class QuestionAnswer
  extend ActiveModel::Naming
  include ActiveModel::Validations

  validates :question, :motion, presence: true

  attr_accessor :question, :motion, :options

  def initialize(question: nil, motion: nil, options: {})
    @question = question
    @motion = motion
    @options = options
  end

  def persisted?
    false
  end

  def question_id
    question.try(:id)
  end

  def save
    return unless same_forum
    Question.transaction do
      UpdateMotion
        .new(@motion,
             attributes: {
               parent: @question.edge,
               question_id: @question.id
             },
             options: @options)
        .on(:update_motion_successful) { return true }
        .on(:update_motion_failed) { return false }
        .commit
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
