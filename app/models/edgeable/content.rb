# frozen_string_literal: true

module Edgeable
  module Content
    extend ActiveSupport::Concern

    included do
      enhance LinkedRails::Enhancements::Creatable
      enhance Loggable
      enhance LinkedRails::Enhancements::Menuable
      enhance Trashable
      enhance LinkedRails::Enhancements::Updatable
      enhance Followable

      auto_strip_attributes :title, squish: true
      auto_strip_attributes :content
      property :display_name, :string, NS::SCHEMA[:name]
      property :description, :text, NS::SCHEMA[:text]
      attribute :pinned, :boolean

      before_save :capitalize_title

      def capitalize_title
        return if display_name.blank?

        display_name[0] = display_name[0].upcase
        self.display_name = display_name
      end

      def pinned
        pinned_at.present?
      end
      alias_method :pinned?, :pinned

      def pinned=(value)
        self.pinned_at = value == '1' ? Time.current : nil
      end
    end
  end
end
