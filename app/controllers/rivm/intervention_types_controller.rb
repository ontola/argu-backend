# frozen_string_literal: true

class InterventionTypesController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def create_service_parent
    ActsAsTenant.current_tenant
  end
end
