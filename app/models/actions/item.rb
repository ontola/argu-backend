# frozen_string_literal: true

module Actions
  class Item < LinkedRails::Actions::Item
    attr_writer :target
    attr_accessor :svg

    collection_options(
      association_base: lambda {
        Actions::Item.sorted_collection_actions(
          self,
          parent ? parent.action_list(user_context) : association_class.app_action_list(user_context)
        )
      },
      default_filters: {
        NS.schema.actionStatus => [NS.schema.PotentialActionStatus, NS.ontola[:LockedActionStatus]]
      },
      title: lambda {
        I18n.t(
          "collections.#{LinkedRails::Translate.translation_key(parent.try(:association_class))}.action_dialog",
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

      def collection_actions(resource, action_list)
        if resource.filter[NS.schema.actionStatus]
          action_list.actions.filter { |action| resource.filter[NS.schema.actionStatus].include?(action.action_status) }
        else
          action_list.actions
        end
      end

      def sorted_collection_actions(resource, action_list)
        return [] if action_list.blank?

        collection_actions(resource, action_list).sort_by do |action|
          resource.parent.try(:action_precedence).try(:index, action.tag.to_sym) || 0
        end
      end
    end
  end
end
