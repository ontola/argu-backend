# frozen_string_literal: true

module Actions
  class Item < LinkedRails::Actions::Item
    attr_writer :target
    attr_accessor :svg

    collection_options(
      association_base: lambda {
        action_list = parent ? parent.action_list(user_context) : association_class.app_action_list(user_context)

        if filter[NS.schema.actionStatus]
          action_list.actions.filter { |action| filter[NS.schema.actionStatus].include?(action.action_status) }
        else
          action_list.actions
        end
      },
      default_filters: {
        NS.schema.actionStatus => [NS.schema.PotentialActionStatus]
      },
      title: lambda {
        I18n.t(
          "collections.#{LinkedRails::Translate.translation_key(parent.association_class)}.action_dialog",
          default: :'actions.plural'
        )
      }
    )

    filterable(
      NS.schema.actionStatus => {
        values: [
          NS.schema.PotentialActionStatus,
          NS.schema.CompletedActionStatus,
          NS.ontola[:ExpiredActionStatus],
          NS.ontola[:DisabledActionStatus]
        ],
        visible: false
      }
    )

    def error
      return super unless action_status == NS.ontola[:DisabledActionStatus]

      resource_policy&.message || super
    end

    class << self
      def app_action_list(_user_context); end
    end
  end
end
