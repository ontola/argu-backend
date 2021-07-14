class MarkAllSubmissionsAsComplete < ActiveRecord::Migration[6.0]
  def change
    Property.create!(
      Submission.pluck(:uuid).map do |edge_id|
        {
          edge_id: edge_id,
          predicate: NS.argu[:submissionStatus],
          integer: Submission.statuses[:submission_completed]
        }
      end
    )
  end
end
