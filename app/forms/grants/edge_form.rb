# frozen_string_literal: true

module Grants
  class EdgeForm < ApplicationForm
    field :group_id,
          datatype: NS.xsd.string,
          max_count: 1,
          min_count: 1,
          input_field: LinkedRails::Form::Field::SelectInput,
          sh_in: -> { ::Group.collection_iri }
    field :grant_set_id,
          datatype: NS.xsd.string,
          min_count: 1,
          max_count: 1,
          input_field: LinkedRails::Form::Field::SelectInput,
          sh_in: lambda {
            [NS.libro[:null]] +
              GrantSet
                .where(root_id: [nil, ActsAsTenant.current_tenant&.uuid])
                .where.not(title: %i[empty staff motion_create])
                .map(&:iri) + [RDF.nil]
          }
  end
end
