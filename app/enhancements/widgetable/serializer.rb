# frozen_string_literal: true

module Widgetable
  module Serializer
    extend ActiveSupport::Concern
    included do
      attribute :widgets_iri, predicate: NS::ONTOLA[:widgets], unless: :export_scope?
    end

    def widgets_iri
      collection_iri(object, :widgets)
    end
  end
end
