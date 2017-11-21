# frozen_string_literal: true

module Edgeable
  class Content < Edgeable::Base
    self.abstract_class = true

    include Actionable
    include Loggable
    include Trashable
    include Menuable
  end
end
