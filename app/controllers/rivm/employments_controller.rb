# frozen_string_literal: true

class EmploymentsController < EdgeableController
  private

  def update_meta
    super + [invalidate_collection_delta(EmploymentModeration.root_collection)]
  end
end
