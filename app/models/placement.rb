class Placement < ActiveRecord::Base
  belongs_to :forum
  belongs_to :place
  belongs_to :placeable, polymorphic: true
  belongs_to :creator, class_name: 'User'

end
