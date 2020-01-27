# frozen_string_literal: true

class ProjectsController < EdgeableController
  skip_before_action :check_if_registered, only: :index
end
