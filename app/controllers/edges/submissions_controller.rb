# frozen_string_literal: true

class SubmissionsController < EdgeableController
  private

  def permit_params
    {
      session_id: session_id
    }
  end
end
