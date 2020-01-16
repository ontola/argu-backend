# frozen_string_literal: true

module Surveyable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :surveys
    end
  end
end
