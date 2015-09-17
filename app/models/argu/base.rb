class Argu::Base < ActiveRecord::Base
  self.abstract_class = true
  include ArguBase

end
