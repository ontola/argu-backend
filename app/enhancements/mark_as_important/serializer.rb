# frozen_string_literal: true

module MarkAsImportant
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :mark_as_important, predicate: NS.argu[:markAsImportant]
      attribute :mark_as_important?, predicate: NS.argu[:important]
    end
  end
end
