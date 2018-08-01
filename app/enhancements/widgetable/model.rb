# frozen_string_literal: true

module Widgetable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :widgets, -> { includes(:owner).order(position: :asc) }, as: :owner, primary_key: :uuid

      after_create :create_default_widgets

      def widget_sequence
        @widget_sequence ||= RDF::Sequence.new(widgets)
      end

      private

      def create_default_widgets
        return unless self.class.class_variables.include?(:@@default_widgets)
        self.class.default_widgets.each do |widget|
          send("create_#{widget}_widget")
        end
      end

      def create_discussions_widget
        widgets
          .discussions
          .create(
            resource_iri: collection_iri(self, :discussions),
            label: 'discussions.plural',
            label_translation: true,
            body: '',
            size: 3
          )
      end
    end

    module ClassMethods
      def default_widgets(*widgets)
        cattr_accessor :default_widgets do
          widgets
        end
      end
    end
  end
end
