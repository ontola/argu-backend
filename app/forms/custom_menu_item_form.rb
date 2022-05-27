# frozen_string_literal: true

class CustomMenuItemForm < ApplicationForm
  def self.edge_target
    LinkedRails::SHACL::PropertyShape.new(
      path: NS.argu[:targetType],
      has_value: -> { CustomMenuItemSerializer.enum_options(:target_type)[:edge].iri }
    )
  end

  def self.url_target
    LinkedRails::SHACL::PropertyShape.new(
      path: NS.argu[:targetType],
      has_value: -> { CustomMenuItemSerializer.enum_options(:target_type)[:url].iri }
    )
  end

  field :target_type, min_count: 1, input_field: LinkedRails::Form::Field::ToggleButtonGroup
  field :edge, if: [edge_target], min_count: 1, sh_in: -> { ActsAsTenant.current_tenant.search_result_collection.iri }
  field :raw_href, if: [url_target], min_count: 1, input_field: LinkedRails::Form::Field::UrlInput
  field :raw_label, if: [edge_target], helper_text: -> { 'Laat leeg om de naam van het item te gebruiken' }
  field :raw_label, if: [url_target], min_count: 1
  field :icon, input_field: IconInput
end
