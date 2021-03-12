# frozen_string_literal: true

class GroupForm < ApplicationForm
  field :display_name
  field :name_singular
  field :require_2fa
end
