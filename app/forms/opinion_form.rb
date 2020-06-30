# frozen_string_literal: true

class OpinionForm < ApplicationForm
  field :description, description: -> { I18n.t('opinions.form.placeholder') }, datatype: NS::FHIR[:markdown]

  footer do
    actor_step
  end

  hidden do
    field :is_opinion
  end
end
