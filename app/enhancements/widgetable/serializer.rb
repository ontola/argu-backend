# frozen_string_literal: true

module Widgetable
  module Serializer
    extend ActiveSupport::Concern
    included do
      attribute :widgets_iri, predicate: NS.ontola[:widgets], unless: method(:export_scope?)
    end
  end
end
