# frozen_string_literal: true

module Grantable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :granted_sets_iri, predicate: NS.argu[:grantedSets], unless: method(:system_scope?)
      attribute :permissions_iri, predicate: NS.argu[:permissions], unless: method(:system_scope?)
      attribute :permission_groups_iri, predicate: NS.argu[:permissionGroups], unless: method(:system_scope?)
    end
  end
end
