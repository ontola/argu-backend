# frozen_string_literal: true

class InterventionTypesController < EdgeableController
  private

  def create_service_parent
    ActsAsTenant.current_tenant
  end
end
