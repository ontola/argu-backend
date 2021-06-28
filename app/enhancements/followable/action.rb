# frozen_string_literal: true

module Followable
  module Action
    extend ActiveSupport::Concern

    included do
      %i[news reactions never].each do |follow_type|
        has_resource_action(
          :"follow_#{follow_type}",
          type: [NS.schema.Action],
          url: -> { follow_iri(follow_type) },
          http_method: :post,
          label: -> { I18n.t("menus.default.#{follow_type}") }
        )
      end

      def follow_iri(follow_type)
        collection_iri(resource, :follows, follow_type: follow_type)
      end
    end
  end
end
