# frozen_string_literal: true

module Topicable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :topics
    end
  end
end
