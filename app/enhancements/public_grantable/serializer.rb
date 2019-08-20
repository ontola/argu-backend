# frozen_string_literal: true

module PublicGrantable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :public_grant, predicate: NS::ARGU[:publicGrant]

      enum :public_grant,
           type: GrantSet.iri,
           options: public_grant_options
    end

    module ClassMethods
      private

      def public_grant_options
        Hash[
          [:none].concat(GrantSet::SELECTABLE_TITLES).map do |title|
            [title.to_sym, {iri: NS::ARGU["grantSet#{title}"], label: -> { I18n.t("roles.types.#{title}").capitalize }}]
          end
        ]
      end
    end
  end
end
