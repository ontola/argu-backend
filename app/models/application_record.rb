# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include LinkedRails::Model
  include ApplicationModel
  include VirtualAttributes

  self.abstract_class = true
end
