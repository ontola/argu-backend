# frozen_string_literal: true

class IncidentsController < EdgeableController
  skip_before_action :check_if_registered, only: :index
end
