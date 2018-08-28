# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ApplicationModel
  include Iriable
  include VirtualAttributes

  self.abstract_class = true
end
