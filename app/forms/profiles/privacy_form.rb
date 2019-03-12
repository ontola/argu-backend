# frozen_string_literal: true

module Profiles
  class PrivacyForm < ApplicationForm
    fields %i[
      are_votes_public
      is_public
    ]
  end
end
