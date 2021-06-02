# frozen_string_literal: true

module Inviteable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :invites

      def invites
        []
      end
    end
  end
end
