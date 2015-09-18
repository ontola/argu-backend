class QuestionAnswer < ActiveRecord::Base
  include ArguBase, Parentable

  belongs_to :question, inverse_of: :question_answers
  belongs_to :motion, inverse_of: :question_answers
  belongs_to :creator, class_name: 'Profile'

  validates :question, :motion, presence: true
  validate :same_forum

  parentable :question

  def same_forum
    if question.forum.present? && motion.forum.present?
      question.forum.id == motion.forum.id
    else
      false
    end
  end
end
