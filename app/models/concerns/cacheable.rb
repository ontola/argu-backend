# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  included do
    include LinkedRails::Model::Cacheable
  end

  private

  def should_publish_changes
    super && !RequestStore.store[:disable_broadcast]
  end
end
