# frozen_string_literal: true

module Grantable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :granted_sets_iri, predicate: NS::ARGU[:grantedSets], unless: method(:system_scope?)
    end
  end
end
