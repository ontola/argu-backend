# frozen_string_literal: true

module Widgetable
  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :widget_sequence, predicate: NS::ARGU[:widgets], unless: :export_scope?
    end
  end
end
