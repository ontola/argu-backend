# frozen_string_literal: true

class GrantForm < ApplicationForm
  field :edge_id,
        datatype: NS::XSD[:string],
        max_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in: -> { ActsAsTenant.current_tenant.self_and_children.map(&:iri) }
  field :group_id,
        datatype: NS::XSD[:string],
        max_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in: -> { [::Group.public.iri].concat(ActsAsTenant.current_tenant.groups.map(&:iri)) }
  field :grant_set_id,
        datatype: NS::XSD[:string],
        max_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in: lambda {
          GrantSet
            .where(root_id: [nil, ActsAsTenant.current_tenant&.uuid])
            .where('title NOT IN (?)', %i[empty staff motion_create])
            .map(&:iri)
        }
end
