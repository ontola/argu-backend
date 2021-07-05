# frozen_string_literal: true

class SubmissionPolicy < EdgePolicy
  permit_attributes %i[status]

  def update?
    return forbid_with_status(NS.schema.ExpiredActionStatus) if expired?
    return forbid_with_status(NS.schema.CompletedActionStatus) if completed?

    is_creator?
  end

  def reward?
    record.parent.reward.positive?
  end

  def show?
    super || new_record? || is_creator?
  end

  private

  def completed?
    record.submission_completed? && record.status_was != 'submission_active'
  end

  def is_creator?
    current_session?
  end
end
