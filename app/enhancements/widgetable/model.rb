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
      widgets.find_each { |w| w.replace_path(previous, iri_path) } if previous != iri_cache
      iri_cache
    end

    private

    def create_default_widgets
      return unless default_widgets.is_a?(Array)

      I18n.with_locale(language) do
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
