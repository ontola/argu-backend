# frozen_string_literal: true

class EmploymentModerationsController < EmploymentsController
  private

  def resource_by_id
    EmploymentModeration.find(super.id)
  end
end
