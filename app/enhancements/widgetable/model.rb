# frozen_string_literal: true

module Widgetable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :widgets, -> { includes(:owner).order(position: :asc) }, as: :owner, primary_key: :uuid

      after_create :create_default_widgets

      class_attribute :default_widgets
    end

    def cache_iri_path!
      previous = iri_cache || iri_path_from_template
      super
      if previous != iri_cache
        widgets.update_all(
          'resource_iri = replace(resource_iri, '\
        "'#{ApplicationRecord.connection.quote_string(previous)}/', "\
        "'#{ApplicationRecord.connection.quote_string(iri_path)}/')"
        )
      end
      iri_cache
    end

    def widget_sequence
      @widget_sequence ||= RDF::Sequence.new(widgets)
    end

    private

    def create_default_widgets
      return unless default_widgets.is_a?(Array)
      default_widgets.each do |widget|
        Widget.send("create_#{widget}", self)
      end
    end

    module ClassMethods
      def default_widgets(*widgets)
        cattr_accessor :default_widgets do
          widgets
        end
      end

      def preview_includes
        super + [widget_sequence: :members]
      end
    end
  end
end
