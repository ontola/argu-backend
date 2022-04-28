# frozen_string_literal: true

module Vocabularies
  class OptionsVocabForm < ApplicationForm
    has_many :terms,
             form: Terms::OptionsTermForm,
             label: '',
             min_count: 1

    hidden do
      field :display_name
    end
  end
end
