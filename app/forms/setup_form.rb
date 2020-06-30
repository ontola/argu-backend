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
  field :first_name, min_count: 1, if: intro_required
  field :first_name, unless: intro_required
  field :last_name, min_count: 1, if: intro_required
  field :last_name, unless: intro_required
end
