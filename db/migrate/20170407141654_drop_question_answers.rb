class DropQuestionAnswers < ActiveRecord::Migration[5.0]
  def up
    drop_table :question_answers
  end
end
