# frozen_string_literal: true

module Argu
  module PagesConstraint
    module_function

    def matches?(request)
      id = request.path_parameters[:root_id] || request.path_parameters[:page_id] || request.path_parameters[:id]
      (/[a-zA-Z]/i =~ id).present?
    end
  end
end
