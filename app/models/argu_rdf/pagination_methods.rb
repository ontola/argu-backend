# frozen_string_literal: true

module ArguRDF
  module PaginationMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def default_per_page
        @_default_per_page
      end

      def max_per_page
        default_per_page
      end
    end
  end
end
