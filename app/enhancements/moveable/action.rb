# frozen_string_literal: true

module Moveable
  module Action
    extend ActiveSupport::Concern

    included do
      define_action(
        :move,
        type: [NS::SCHEMA[:Action], NS::SCHEMA[:MoveAction]],
        policy: :move?,
        image: 'fa-sitemap',
        url: -> { move_iri(resource) },
        http_method: :put,
        form: MoveRequestForm,
        iri_template: :move_iri
      )
    end
  end
end
