# frozen_string_literal: true

class TransferForm < ApplicationForm
  self.abstract_form = true

  field :transfer_type,
        path: NS.argu[:transferType],
        label: -> { I18n.t('forms.transfers.transfer_type.label') },
        min_count: 1,
        input_field: LinkedRails::Form::Field::ToggleButtonGroup,
        sh_in: form_options_iri(:transfer_type, Edge)
  field :transfer_to,
        min_count: 1,
        max_count: 1,
        label: -> { '' },
        if: [
          LinkedRails::SHACL::PropertyShape.new(
            path: NS.argu[:transferType],
            has_value: -> { EdgeSerializer.enum_options(:transfer_type)[:transfer_to_user].iri }
          )
        ],
        path: NS.argu[:transferTo],
        sh_in: -> { User.root_collection.search_result_collection.iri }
end
