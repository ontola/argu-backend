# frozen_string_literal: true

class MeasureTypesController < EdgeableController
  private

  def create_service_parent
    ActsAsTenant.current_tenant
  end
end
