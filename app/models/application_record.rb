# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Iriable

  self.abstract_class = true

  %w[comment page forum question motion argument project blog_post group edge].each do |model|
    require_dependency model
  end

  def class_name
    self.class.name.tableize
  end

  def self.class_name
    name.tableize
  end

  def edited?
    updated_at - 2.minutes > created_at
  end

  def identifier
    "#{class_name}_#{id}"
  end
end
