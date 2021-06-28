# frozen_string_literal: true

module Grants
  class EdgeForm < ApplicationForm
    field :group_id,
          datatype: NS.xsd.string,
          max_count: 1,
          input_field: LinkedRails::Form::Field::SelectInput,
          sh_in: -> { [::Group.public.iri].concat(ActsAsTenant.current_tenant.groups.map(&:iri)) }
    field :grant_set_id,
          datatype: NS.xsd.string,
          max_count: 1,
          input_field: LinkedRails::Form::Field::SelectInput,
          sh_in: lambda {
            GrantSet
              .where(root_id: [nil, ActsAsTenant.current_tenant&.uuid])
              .where('title NOT IN (?)', %i[empty staff motion_create])
              .map(&:iri)
          }
  end
end
