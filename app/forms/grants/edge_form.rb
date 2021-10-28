# frozen_string_literal: true

module Grants
  class EdgeForm < ApplicationForm
    field :group_id,
          datatype: NS.xsd.string,
          max_count: 1,
          input_field: LinkedRails::Form::Field::SelectInput,
          sh_in: -> { ::Group.root_collection.search_result_collection.iri }
    field :grant_set_id,
          datatype: NS.xsd.string,
          max_count: 1,
          input_field: LinkedRails::Form::Field::SelectInput,
          sh_in: lambda {
            GrantSet
              .where(root_id: [nil, ActsAsTenant.current_tenant&.uuid])
              .where.not(title: %i[empty staff motion_create])
              .map(&:iri)
          }
  end
end
