# frozen_string_literal: true

module Edgeable
  class Content < Edgeable::Base
    self.abstract_class = true

    include Loggable
    include Trashable
  end
end
