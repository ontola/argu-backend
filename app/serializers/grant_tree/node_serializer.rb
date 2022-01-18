# frozen_string_literal: true

class GrantTree
  class NodeSerializer < BaseSerializer
    attribute :title, predicate: NS.schema.name
    attribute :description, predicate: NS.schema.text
    has_one :edgeable_record, predicate: NS.schema.isPartOf
    with_collection :permission_groups, predicate: NS.argu[:permissionGroups]
    with_collection :grants, predicate: NS.argu[:grants]
  end
end
