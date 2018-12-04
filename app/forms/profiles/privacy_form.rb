# frozen_string_literal: true

module Profiles
  class PrivacyForm < RailsLD::Form
    fields %i[
      are_votes_public
      is_public
    ]
  end
end
