# frozen_string_literal: true
class QuestionAnswer
  extend ActiveModel::Naming
  include ActiveModel::Validations

  validates_presence_of :question, :motion

  attr_accessor :question, :motion, :options

  def initialize(question: nil, motion: nil, options: {})
    @question, @motion, @options = question, motion, options
  end

  def persisted?
    false
  end

  def question_id
    question.try(:id)
  end

  def save
    if same_forum
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
