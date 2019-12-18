# frozen_string_literal: true

class ScenariosController < EdgeableController
  skip_before_action :check_if_registered, only: :index
end
