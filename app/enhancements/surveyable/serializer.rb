# frozen_string_literal: true

module Surveyable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :surveys, predicate: NS.argu[:surveys]
    end
  end
end
