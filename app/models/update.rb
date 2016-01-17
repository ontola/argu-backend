class Update < ActiveRecord::Base
  include ArguBase, Trashable, Flowable, Placeable

  belongs_to :forum
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

end
