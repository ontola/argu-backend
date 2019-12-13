# frozen_string_literal: true

module CustomActionable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many_children :custom_actions
      with_collection :custom_actions
    end

    module ClassMethods
      def preview_includes
        super + %i[custom_actions]
      end
    end
  end
end
