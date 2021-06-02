# frozen_string_literal: true

module Contactable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :direct_messages

      def direct_messages
        []
      end
    end
  end
end
