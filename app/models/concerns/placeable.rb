# frozen_string_literal: true
module Placeable
  extend ActiveSupport::Concern

  included do
    has_many :placements, as: :placeable, dependent: :destroy
    has_many :places, through: :placements
    accepts_nested_attributes_for :placements, allow_destroy: true
  end

  module ClassMethods
  end
end
