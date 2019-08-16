# frozen_string_literal: true

class RisksController < EdgeableController
  skip_before_action :check_if_registered, only: :index
end
