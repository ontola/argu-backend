class AddCreatorIdToQuestionAnswers < ActiveRecord::Migration
  def up
    add_column :question_answers, :creator_id, :integer
    add_foreign_key :question_answers, :profiles, column: :creator_id
  end

  def down
    remove_column :question_answers, :creator
  end
end
