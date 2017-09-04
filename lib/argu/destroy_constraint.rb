# frozen_string_literal: true

module Argu
  module DestroyConstraint
    module_function

    def matches?(request)
      request.query_parameters['destroy'] == 'true'
    end
  end
end
