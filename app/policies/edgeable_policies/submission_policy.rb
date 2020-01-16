# frozen_string_literal: true

class SubmissionPolicy < EdgePolicy
  def create?
    record.parent.submission_for(user).blank?
  end
end
