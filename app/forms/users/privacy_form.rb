# frozen_string_literal: true

module Users
  class PrivacyForm < ApplicationForm
    fields [
      :has_analytics,
      {profile: {referred_shapes: [Profiles::PrivacyForm]}},
      delete_button: {
        type: :resource,
        url: -> { delete_iri(user_context.user) }
      }
    ]
  end
end
