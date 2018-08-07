# frozen_string_literal: true

module Updateable
  module Action
    extend ActiveSupport::Concern

    included do
      define_action(
        :update,
        type: NS::SCHEMA[:UpdateAction],
        policy: :update?,
        image: 'fa-update',
        url: -> { resource.iri },
        http_method: :put,
        form: -> { "#{resource.class}Form".safe_constantize },
        iri_template: :edit_iri
      )
    end
  end
end
