# frozen_string_literal: true

module Users
  class PrivacyForm < FormsBase
    fields %i[
      has_analytics
    ]
    field :profile, referred_shapes: [Profiles::PrivacyForm]
  end
end
