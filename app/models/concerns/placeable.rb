# frozen_string_literal: true
module Placeable
  extend ActiveSupport::Concern

  included do
    has_many :placements, as: :placeable, dependent: :destroy
    has_many :custom_placements,
             -> { custom },
             class_name: 'Placement',
             as: :placeable,
             inverse_of: :placeable
    has_one :country_placement,
            -> { country },
            class_name: 'Placement',
            as: :placeable,
            inverse_of: :placeable
    has_one :home_placement,
            -> { home },
            class_name: 'Placement',
            as: :placeable,
            inverse_of: :placeable
    has_many :places, through: :placements
    accepts_nested_attributes_for :placements, allow_destroy: true
  end

  module ClassMethods
  end
end
