# frozen_string_literal: true

class InterventionTypesController < EdgeableController
  skip_before_action :check_if_registered, only: :index
end
