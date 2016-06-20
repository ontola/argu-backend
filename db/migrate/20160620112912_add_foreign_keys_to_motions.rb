class AddForeignKeysToMotions < ActiveRecord::Migration
  def up
    Motion
      .where('question_id IS NOT NULL')
      .joins('LEFT OUTER JOIN questions ON questions.id = motions.question_id')
      .where('questions.id IS NULL')
      .update_all(question_id: nil)
    add_foreign_key :motions, :forums
    add_foreign_key :motions, :questions
  end

  def down
    remove_foreign_key :motions, :forums
    remove_foreign_key :motions, :questions
  end
end
