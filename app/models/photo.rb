class Photo < ActiveRecord::Base
  belongs_to :forum
  belongs_to :about, polymorphic: true
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

end
