class SanitizeOpinions < ActiveRecord::Migration[5.1]
  def change
    Vote.where(explanation: '').update_all(explanation: nil)
    Vote.where(explanation: nil).update_all(explained_at: nil)
  end
end
