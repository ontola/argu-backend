# frozen_string_literal: true

module Pollable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :polls
    end
  end
end
