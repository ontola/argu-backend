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
        url: -> { resource.iri(destroy: true) },
        http_method: :delete,
        iri_template: :delete_iri
      )
    end
  end
end
