# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ApplicationModel
  include Iriable

  self.abstract_class = true

  %w[comment page forum question motion notification argument blog_post group edge].each do |model|
    require_dependency model
  end
end
