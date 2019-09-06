# frozen_string_literal: true

class InterventionsController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def permit_params
    super.except(:parent_id)
  end

  def create_service_parent
    Edge.find_by!(fragment: params.require(:intervention).require(:parent_id))
  end
end
