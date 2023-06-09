# frozen_string_literal: true

module Followable
  module Controller
    extend ActiveSupport::Concern

    included do
      %i[news reactions never].each do |follow_type|
        has_resource_action(
          :"follow_#{follow_type}",
          http_method: :post,
          description: -> { I18n.t("actions.follows.#{follow_type}.description", item: resource.display_name) },
          label: -> { I18n.t("actions.follows.#{follow_type}.label") },
          submit_label: -> { I18n.t("actions.follows.#{follow_type}.submit") },
          target_url: -> { resource.follow_iri(follow_type) },
          type: [NS.schema.Action]
        )
      end
    end
  end
end
