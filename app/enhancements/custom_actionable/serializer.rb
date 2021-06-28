# frozen_string_literal: true

module CustomActionable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :custom_actions, predicate: NS.argu[:customActions]

      has_many :custom_actions
    end
  end
end
