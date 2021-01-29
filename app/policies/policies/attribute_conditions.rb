# frozen_string_literal: true

module Policies
  module AttributeConditions
    extend ActiveSupport::Concern
    included do
      extend UriTemplateHelper
    end

    private

    def check_creator(_opts)
      is_creator?
    end

    def check_grant_sets(grant_sets)
      grant_sets.any? { |grant_set| has_grant_set?(grant_set) }
    end

    module ClassMethods
      private

      def creator_shapes(_opts)
        [
          LinkedRails::SHACL::PropertyShape.new(
            path: [NS::SCHEMA[:creator]],
            sh_in: -> { actors_iri }
          )
        ]
      end

      def grant_sets_shapes(grant_sets)
        [
          LinkedRails::SHACL::PropertyShape.new(
            path: [NS::ARGU[:grantedSets], NS::RDFS.member, NS::ARGU[:grantSetKey]],
            sh_in: grant_sets
          )
        ]
      end
    end
  end
end
