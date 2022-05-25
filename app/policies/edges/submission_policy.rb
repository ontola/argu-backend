# frozen_string_literal: true

class SubmissionPolicy < EdgePolicy
  permit_attributes %i[status]
  permit_attributes %i[coupon], has_values: {require_coupon: true}

  def update?
    return forbid_with_status(NS.schema.ExpiredActionStatus) if expired?
    return forbid_with_status(NS.schema.CompletedActionStatus) if completed?

    is_creator?
  end

  def show?
    super || new_record? || is_creator?
  end

  private

  def completed?
    record.submission_completed? && record.status_was != 'submission_active'
  end

  def is_creator?
    return current_session? if record.creator_id == User::GUEST_ID

    record.publisher_id == user.id
  end
end
