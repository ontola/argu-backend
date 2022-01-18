# frozen_string_literal: true

class GrantResetForm < ApplicationForm
  field :edge_id,
        datatype: NS.xsd.string,
        max_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in: -> { ActsAsTenant.current_tenant.search_result_collection.iri }
  field :resource_type
  field :action_name
end
