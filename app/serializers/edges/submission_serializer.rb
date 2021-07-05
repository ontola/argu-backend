# frozen_string_literal: true

class SubmissionSerializer < EdgeSerializer
  has_one :submission_data, predicate: NS.argu[:submissionData]
end
