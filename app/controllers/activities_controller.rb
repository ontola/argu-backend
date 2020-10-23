# frozen_string_literal: true

class ActivitiesController < AuthorizedController
  after_action :set_cache_control_public, only: :show, if: :valid_response?

  active_response :show
end
