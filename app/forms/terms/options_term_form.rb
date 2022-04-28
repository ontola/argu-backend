# frozen_string_literal: true

module Terms
  class OptionsTermForm < ApplicationForm
    field :display_name,
          label: '',
          placeholder: ''

    hidden do
      field :position
    end
  end
end
