# frozen_string_literal: true

module Measureable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :measures
    end
  end
end
