class RemoveQuestionAnswers < ActiveRecord::Migration
  def up
    add_column :motions,
               :question_id,
               :integer
    add_column :question_answers,
               :migrated,
               :boolean,
               default: false,
               null: false

    QuestionAnswer.find_in_batches do |batch|
      batch.each do |qa|
        Motion.find(qa.motion_id).update(question_id: qa.question_id)
        qa.update migrated: true
      end
    end
  end

  def down
    remove_column :motions, :question_id
    remove_column :question_answers, :migrated
  end
end
