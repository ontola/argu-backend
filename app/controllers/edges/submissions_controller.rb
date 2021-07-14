# frozen_string_literal: true

class SubmissionsController < EdgeableController
  private

  def allow_empty_params?
    true
  end
end
