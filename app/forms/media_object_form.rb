# frozen_string_literal: true

class MediaObjectForm < ApplicationForm
  def self.is_local
    LinkedRails::SHACL::PropertyShape.new(
      path: NS::ARGU[:contentSource],
      has_value: -> { MediaObjectSerializer.enum_options(:content_source)[:local].iri }
    )
  end

  def self.is_remote
    LinkedRails::SHACL::PropertyShape.new(
      path: NS::ARGU[:contentSource],
      has_value: -> { MediaObjectSerializer.enum_options(:content_source)[:remote].iri }
    )
  end

  include LinkedRails::Policy::AttributeConditions
  field :content_source, input_field: LinkedRails::Form::Field::ToggleButtonGroup, min_count: 1
  field :content, if: [is_local], min_count: 1
  field :remote_content_url, if: [is_remote], min_count: 1

  hidden do
    field :content_type, sh_in: -> { MediaObject.content_type_white_list }
    field :filename
  end
end
