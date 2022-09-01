# frozen_string_literal: true

class GrantForm < ApplicationForm
  field :edge_id,
        datatype: NS.xsd.string,
        min_count: 1,
        max_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in: -> { ActsAsTenant.current_tenant.search_result_collection.iri }
  field :group_id,
        datatype: NS.xsd.string,
        min_count: 1,
        max_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in: -> { ::Group.root_collection.search_result_collection.iri }
  field :grant_set_id,
        datatype: NS.xsd.string,
        min_count: 1,
        max_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in: lambda {
          GrantSet
            .where(root_id: [nil, ActsAsTenant.current_tenant&.uuid])
            .where.not(title: %i[empty motion_create])
            .map(&:iri)
        }
end
