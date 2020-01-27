# frozen_string_literal: true

module Phaseable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :phases
    end
  end
end
