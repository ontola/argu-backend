# frozen_string_literal: true

module InterventionTypeable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :intervention_type_examples,
               primary_key_property: :example_of_id,
               class_name: 'InterventionType',
               dependent: false

      with_collection :intervention_types,
                      association: :intervention_type_examples,
                      title: ->(r) { I18n.t('intervention_types.collection_for', parent: r.display_name.downcase) }
    end
  end
end
