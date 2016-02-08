class Place < ActiveRecord::Base
  has_many :placements
  has_many :placeables,
           through: :placements
end
