class AddExpiresAtToMotions < ActiveRecord::Migration[5.0]
  def change
    add_column :edges, :expires_at, :datetime

    Question.where('expires_at IS NOT NULL').find_each do |question|
      question.edge.update!(expires_at: question.expires_at)
    end
  end
end
