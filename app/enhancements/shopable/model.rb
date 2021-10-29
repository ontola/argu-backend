# frozen_string_literal: true

module Shopable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :orders
      with_collection :offers
    end
  end
end
