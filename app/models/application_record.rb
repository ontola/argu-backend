# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  %w[comment page forum question motion argument project blog_post group].each do |model|
    require_dependency model
  end

  def class_name
    self.class.name.tableize
  end

  def self.class_name
    name.tableize
  end

  def context_id
    Rails.application.routes.url_helpers.url_for(action: 'show', controller: class_name, id: id)
  rescue ActionController::UrlGenerationError
    id
  end

  def edited?
    updated_at - 2.minutes > created_at
  end

  def identifier
    "#{class_name}_#{id}"
  end
end
