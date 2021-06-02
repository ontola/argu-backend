# frozen_string_literal: true

module ConfirmedDestroyable
  module Action
    extend ActiveSupport::Concern

    included do
      has_resource_destroy_action(confirmed_destroy_options)
    end

    module ClassMethods
      private

      def confirmed_destroy_options(overwrite = {})
        {
          form: Request::ConfirmedDestroyRequestForm,
          root_relative_iri: lambda {
            expand_uri_template(:delete_iri, parent_iri: split_iri_segments(resource.root_relative_iri))
          }
        }.merge(overwrite)
      end
    end
  end
end
