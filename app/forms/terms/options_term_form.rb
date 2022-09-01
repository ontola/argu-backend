# frozen_string_literal: true

module Terms
  class OptionsTermForm < ApplicationForm
    field :display_name,
          label: '',
          placeholder: '',
          max_length: 35

    hidden do
      field :position
    end
  end
end
