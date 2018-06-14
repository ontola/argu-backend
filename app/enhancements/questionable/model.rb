# frozen_string_literal: true

module Questionable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :questions, pagination: true
    end
  end
end
