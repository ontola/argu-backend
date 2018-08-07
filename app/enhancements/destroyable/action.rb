# frozen_string_literal: true

module Destroyable
  module Action
    extend ActiveSupport::Concern

    included do
      define_action(
        :destroy,
        type: [NS::SCHEMA[:Action], NS::ARGU[:DestroyAction]],
        policy: :destroy?,
        image: 'fa-close',
        url: -> { resource.iri },
        http_method: :delete
      )
    end
  end
end
