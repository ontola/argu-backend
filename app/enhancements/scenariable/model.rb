# frozen_string_literal: true

module Scenariable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :scenarios
    end
  end
end
