# frozen_string_literal: true

module Widgetable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :widgets, -> { includes(:owner).order(position: :asc) }, as: :owner, primary_key: :uuid
      with_collection :widgets

      after_create :create_default_widgets

      class_attribute :default_widgets
    end

    def widgets_iri
      widget_collection.default_view.members_iri
    end

    private

    def create_default_widgets
      return unless default_widgets.is_a?(Array)

      I18n.with_locale(root.language) do
        ActsAsTenant.with_tenant(root) do
          default_widgets.each do |widget|
            Widget.send("create_#{widget}", self)
          end
        end
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
