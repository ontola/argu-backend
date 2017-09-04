# frozen_string_literal: true

module Argu
  module ForumsConstraint
    module_function

    def matches?(request)
      (/[a-zA-Z]/i =~ (request.path_parameters[:forum_id] || request.path_parameters[:id])).present?
    end
  end
end
