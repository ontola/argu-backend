# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ApplicationModel
  include RailsLD::Model
  include VirtualAttributes

  self.abstract_class = true
end
