# frozen_string_literal: true

module ConfirmedDestroyable
  module Action
    extend ActiveSupport::Concern

    included do
      has_action(:destroy, confirmed_destroy_options)
    end

    module ClassMethods
      private

      def confirmed_destroy_options
        {
          type: [NS::SCHEMA[:Action], NS::ARGU[:DestroyAction]],
          policy: :destroy?,
          image: 'fa-close',
          url: -> { resource.iri(destroy: true) },
          http_method: :delete,
          form: Request::ConfirmedDestroyRequestForm,
          root_relative_iri: -> { expand_uri_template(:delete_iri, parent_iri: split_iri_segments(resource.iri_path)) }
        }
      end
    end
  end
end
