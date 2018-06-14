# frozen_string_literal: true

module Motionable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :motions, pagination: true
    end
  end
end
