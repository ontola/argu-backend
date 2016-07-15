# frozen_string_literal: true
module Argu
  module DestroyConstraint
    extend self

    def matches?(request)
      request.query_parameters['destroy'] == 'true'
    end
  end
end
