# frozen_string_literal: true

class SurveysController < EdgeableController
  private

  def update_meta
    super + [
      invalidate_resource_delta(current_resource.menu(:settings))
    ]
  end
end
