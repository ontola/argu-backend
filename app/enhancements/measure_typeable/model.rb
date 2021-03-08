# frozen_string_literal: true

module MeasureTypeable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :measure_type_examples,
               primary_key_property: :example_of_id,
               class_name: 'measureType',
               dependent: false

      with_collection :measure_types,
                      association: :measure_type_examples,
                      default_title: ->(r) { I18n.t('measure_types.collection_for', parent: r.display_name.downcase) }
    end
  end
end
