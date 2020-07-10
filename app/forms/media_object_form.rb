# frozen_string_literal: true

class MediaObjectForm < ApplicationForm
  def self.policy_class
    MediaObject
  end

  include LinkedRails::Policy::AttributeConditions
  field :content_source, input_field: LinkedRails::Form::Field::ToggleButtonGroup, min_count: 1
  field :content, if: has_values_shapes(content_source: :local), min_count: 1
  field :remote_content_url, if: has_values_shapes(content_source: :remote), min_count: 1

  hidden do
    field :content_type, sh_in: -> { MediaObject.content_type_white_list }
  end
end
