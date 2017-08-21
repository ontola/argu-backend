# frozen_string_literal: true
class PermittedAttribute < ApplicationRecord
  belongs_to :permitted_action
end
