# frozen_string_literal: true

class GrantForm < ApplicationForm
  fields [
    {
      edge_id: {
        datatype: NS::XSD[:string],
        max_count: 1,
        sh_in: -> { target.root.self_and_children.map(&:iri) }
      }
    },
    {
      group_id: {
        datatype: NS::XSD[:string],
        max_count: 1,
        sh_in: -> { [Group.public.iri].concat(target.root.groups.map(&:iri)) }
      }
    },
    {
      grant_set_id: {
        datatype: NS::XSD[:string],
        max_count: 1,
        sh_in: lambda {
          GrantSet
            .where(root_id: [nil, ActsAsTenant.current_tenant&.uuid])
            .where('title NOT IN (?)', %i[empty staff motion_create])
            .map(&:iri)
        }
      }
    }
  ]
end
