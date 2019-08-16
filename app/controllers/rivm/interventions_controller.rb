# frozen_string_literal: true

class InterventionsController < EdgeableController
  skip_before_action :check_if_registered, only: :index
end
