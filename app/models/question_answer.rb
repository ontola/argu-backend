class QuestionAnswer < ActiveRecord::Base
  belongs_to :question, inverse_of: :question_answers
  belongs_to :motion, inverse_of: :question_answers
end
