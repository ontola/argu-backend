# frozen_string_literal: true

module Policies
  module AttributeConditions
    extend ActiveSupport::Concern
    included do
      extend URITemplateHelper
    end

    private

    def check_creator(_opts)
      is_creator?
    end

    def check_grant_sets(grant_sets)
      grant_sets.any? { |grant_set| has_grant_set?(grant_set) }
    end

    def check_feature_enabled(feature)
      return true if staff?

      ActsAsTenant.current_tenant.feature_enabled?(feature)
    end

    def check_staff(check)
      staff? == check
    end

    module ClassMethods
      private

      def creator_shapes(_opts)
        [
          LinkedRails::SHACL::PropertyShape.new(
            path: [NS.schema.creator],
            sh_in: -> { actors_iri }
          )
        ]
      end

      def grant_sets_shapes(grant_sets)
        [
          LinkedRails::SHACL::PropertyShape.new(
            path: [NS.argu[:grantedSets], NS.rdfs.member, NS.argu[:grantSetKey]],
            sh_in: grant_sets
          )
        ]
      end

      def feature_enabled_shapes(feature)
        [
          LinkedRails::SHACL::PropertyShape.new(
            path: [NS.argu[:tierLevel]],
            min_inclusive: Rails.application.config.tiers[feature],
            target_node: -> { current_actor_iri }
          )
        ]
      end

      def staff_shapes(check)
        [
          LinkedRails::SHACL::PropertyShape.new(
            path: [NS.argu[:staff]],
            has_value: check,
            target_node: -> { current_actor_iri }
          )
        ]
      end
    end
  end
end
