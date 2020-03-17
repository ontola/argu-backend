# frozen_string_literal: true

class EmploymentModerationsController < EmploymentsController
  private

  def resource_by_id
    EmploymentModeration.find_by(id: super&.id)
  end
end
