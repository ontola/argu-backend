# frozen_string_literal: true

module Topicable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :topics
    end

    module ClassMethods
      def show_includes
        super + [
          topic_collection: inc_shallow_collection
        ]
      end
    end
  end
end
