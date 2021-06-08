# frozen_string_literal: true

class SetupForm < ApplicationForm
  include UsersHelper

  class << self
    def intro_required
      @intro_required ||= [
        LinkedRails::SHACL::PropertyShape.new(
          path: [NS::ONTOLA[:organization], NS::ONTOLA[:requiresIntro]],
          has_value: true
        )
      ]
    end
  end

  field :url
  field :display_name, min_count: 1, if: intro_required
  field :display_name, unless: intro_required
end
