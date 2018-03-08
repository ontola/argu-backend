# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ApplicationModel
  include Iriable

  self.abstract_class = true
end
