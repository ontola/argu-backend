# frozen_string_literal: true

module Users
  class ForumsController < EdgeableController
    skip_before_action :authorize_action, only: %i[index]
  end
end
