# frozen_string_literal: true

module Edgeable
  module Content
    extend ActiveSupport::Concern

    included do
      include Actionable
      include Loggable
      include Trashable
      include Menuable

      property :display_name, :string, NS::SCHEMA[:name]
      property :description, :text, NS::SCHEMA[:text]

      def capitalize_title
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