# frozen_string_literal: true

module Followable
  module Action
    extend ActiveSupport::Concern

    included do
      %i[news reactions never].each do |follow_type|
        has_action(
          :"follow_#{follow_type}",
          type: [NS::SCHEMA[:Action]],
          url: -> { follow_iri(follow_type) },
          http_method: :post,
          label: I18n.t("menus.default.#{follow_type}")
        )
      end

      def follow_iri(follow_type)
        RDF::DynamicURI(
          expand_uri_template(:follows_iri, gid: resource.uuid, follow_type: follow_type, with_hostname: true)
        )
      end
    end
  end
end
