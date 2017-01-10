# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  attr_accessor :potential_action

  def class_name
    self.class.name.tableize
  end

  def self.class_name
    name.tableize
  end

  def context_id
    Rails.application.routes.url_helpers.url_for(action: 'show', controller: class_name, id: id)
  end

  def edited?
    updated_at - 2.minutes > created_at
  end

  def identifier
    "#{class_name}_#{id}"
  end
end
