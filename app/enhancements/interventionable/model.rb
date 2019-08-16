# frozen_string_literal: true

module Interventionable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :interventions
    end
  end
end
