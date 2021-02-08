# frozen_string_literal: true

module Offerable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :order
      with_collection :offers
    end
  end
end
