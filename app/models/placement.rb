class Placement < ActiveRecord::Base
  belongs_to :forum
  belongs_to :place
  belongs_to :placeable, polymorphic: true

end
