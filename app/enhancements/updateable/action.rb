# frozen_string_literal: true

module Updateable
  module Action
    extend ActiveSupport::Concern

    included do
      define_action(
        :update,
        type: NS::SCHEMA[:UpdateAction],
        policy: :update?,
        image: :update,
        url: -> { resource.iri },
        http_method: :put
      )
    end
  end
end
