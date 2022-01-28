# frozen_string_literal: true

require 'linked_rails/form'

LinkedRails::Form.define_singleton_method :preview_includes do
  [pages: [
    :footer_group,
    groups: [fields: [:fail, :pass, shape: [:property, nested_shapes: :property]]]
  ]]
end
