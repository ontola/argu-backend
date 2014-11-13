class CreateQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :question_answers do |t|
      t.references :question
      t.references :statement
      t.integer :votes_pro_count, default: 0
      t.integer :votes_con_count, default: 0
      t.timestamps
    end
  end
end
