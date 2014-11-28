class QuestionAnswer < ActiveRecord::Base
  belongs_to :question, inverse_of: :question_answers
  belongs_to :motion, inverse_of: :question_answers

  validates :question_id, :motion_id, presence: true
  validate :same_forum

  def same_forum
    if question.forum.present? && motion.forum.present?
      question.forum.id == motion.forum.id
    else
      false
    end
  end
end
