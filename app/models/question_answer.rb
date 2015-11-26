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

  def update_counters
    vote_counts = self.votes.group('"for"').count
    self.update votes_pro_count: vote_counts[Vote.fors[:pro]] || 0,
                votes_con_count: vote_counts[Vote.fors[:con]] || 0
  end
end
