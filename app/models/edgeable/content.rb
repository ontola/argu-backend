# frozen_string_literal: true

module Edgeable
  module Content
    extend ActiveSupport::Concern

    included do
      enhance LinkedRails::Enhancements::Creatable
      enhance LinkedRails::Enhancements::Updatable
      enhance Loggable
      enhance Trashable
      enhance Followable

      auto_strip_attributes :title, squish: true
      auto_strip_attributes :content
      property :display_name, :string, NS.schema.name
      property :description, :text, NS.schema.text
      attribute :pinned, :boolean

      before_save :capitalize_title

      def capitalize_title
        return if display_name.blank?

        display_name[0] = display_name[0].upcase
        self.display_name = display_name
      end
    end
  end
end
