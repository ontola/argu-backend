# frozen_string_literal: true

module Users
  class PrivacyForm < ApplicationForm
    fields %i[
      has_analytics
    ]
    field :profile, referred_shapes: [Profiles::PrivacyForm]
  end
end
