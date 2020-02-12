# frozen_string_literal: true

module GrantResettable
  module Model
    extend ActiveSupport::Concern

    included do
      after_save :sync_grants

      cattr_accessor :custom_grants, default: []

      accepts_nested_attributes_for :grant_resets, allow_destroy: true, reject_if: :all_blank

      def self.custom_grants_for(child_type, action) # rubocop:disable Metrics/AbcSize
        singular = child_type.to_s.singularize
        child_class = child_type.to_s.classify.constantize
        raise "#{child_type} is not a child of #{class_name}" unless child_class.valid_parent?(self)

        custom_grants << [singular, action]
        method_identifier = "#{action}_#{singular}"

        attribute "reset_#{method_identifier}"
        attribute "#{method_identifier}_group_ids"

        define_method "reset_#{method_identifier}" do
          reset_custom_grant(action, singular)
        end

        define_method "reset_#{method_identifier}=" do |value|
          boolean = sanitized_reset_custom_grant(value)
          unless boolean == send("reset_#{method_identifier}")
            send("reset_#{method_identifier}_will_change!")
            send("#{method_identifier}_group_ids_will_change!")
          end
          super(boolean)
        end

        define_method "#{method_identifier}_group_ids" do |grant_tree = nil|
          custom_grant_group_ids(action, singular, grant_tree) || []
        end

        define_method "#{method_identifier}_group_ids=" do |value|
          ids = sanitized_custom_grant_group_ids(value).sort
          send("#{method_identifier}_group_ids_will_change!") if ids != send("#{method_identifier}_group_ids")
          super(ids)
        end
      end

      def create_grants_for(resource_type, action, group_ids)
        group_ids.each do |group_id|
          Grant.create!(
            edge: self,
            group_id: group_id,
            grant_set: GrantSet.for_one_action(resource_type, action)
          )
        end
      end

      def custom_grant_group_ids(action, singular, grant_tree)
        return attributes["#{action}_#{singular}_group_ids"] unless attributes["#{action}_#{singular}_group_ids"].nil?

        grant_tree ||= GrantTree.new(persisted_edge.root)
        attributes["#{action}_#{singular}_group_ids"] =
          grant_tree
            .granted_group_ids(
              persisted_edge,
              action: 'create',
              resource_type: singular.classify,
              parent_type: self.class.name
            )
      end

      def grant_reset_for(action, resource_type)
        @grant_resets_for ||= {}
        @grant_resets_for[action] ||= {}
        return @grant_resets_for[action][resource_type] if @grant_resets_for[action].key?(resource_type)

        @grant_resets_for[action][resource_type] =
          grant_resets.find_by(action: action, resource_type: resource_type)
      end

      def remove_grants_for(resource_type, action, group_ids = nil)
        scope = grants.where(grant_set_id: GrantSet.for_one_action(resource_type, action).id)
        group_ids.present? ? scope.where(group_id: group_ids).destroy_all : scope.destroy_all
      end

      def reset_custom_grant(action, singular)
        return attributes["reset_#{action}_#{singular}"] unless attributes["reset_#{action}_#{singular}"].nil?

        grant_reset_for(action, singular.classify).present?
      end

      def sanitized_custom_grant_group_ids(value)
        value.select(&:present?).map(&:to_i)
      end

      def sanitized_reset_custom_grant(value)
        [true, 'true'].include?(value)
      end

      def sync_custom_grants(action, singular)
        return unless send("reset_#{action}_#{singular}")

        granted_group_ids = send("#{action}_#{singular}_group_ids")
        current_granted_group_ids =
          if send("saved_change_to_reset_#{action}_#{singular}?")
            []
          else
            send("#{action}_#{singular}_group_ids_was")
          end
        remove_grants_for(singular.classify, 'create', current_granted_group_ids - granted_group_ids)
        create_grants_for(singular.classify, 'create', granted_group_ids - current_granted_group_ids)
      end

      def sync_grant_reset(action, singular)
        if send("reset_#{action}_#{singular}")
          if grant_reset_for(action, singular.classify).nil?
            grant_resets.create!(action: action, resource_type: singular.classify)
          end
        else
          grant_reset_for(action, singular.classify)&.destroy!
          remove_grants_for(singular.classify, 'create')
        end
      end

      def sync_grants
        custom_grants.each do |singular, action|
          sync_grant_reset(action, singular) if send("saved_change_to_reset_#{action}_#{singular}?")
          sync_custom_grants(action, singular) if send("saved_change_to_#{action}_#{singular}_group_ids?")
        end
      end
    end
  end
end
