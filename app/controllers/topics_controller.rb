# frozen_string_literal: true

class TopicsController < DiscussionsController
  skip_before_action :check_if_registered, only: :index
end
