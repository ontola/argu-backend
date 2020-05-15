# frozen_string_literal: true

module Actions
  class ItemSerializer < LinkedRails::Actions::ItemSerializer
    attribute :url, predicate: NS::SCHEMA[:url] do |object|
      object.target[:id] if object.target.is_a?(Hash)
    end
  end
end
