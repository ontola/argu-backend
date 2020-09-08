# frozen_string_literal: true

class EmploymentModerationsController < EmploymentsController
  private

  def requested_resource
    EmploymentModeration.find_by(id: super&.id)
  end
end
