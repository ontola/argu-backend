# frozen_string_literal: true

module Argu
  # The generic Argu error handling code. Currently a mess from different error
  # classes with inconsistent attributes.
  module ErrorHandling
    module Helpers
      def error_id(e)
        Argu::ERROR_TYPES[e.class].try(:[], :id) || 'BAD_REQUEST'
      end

      def error_mode(exception)
        @_error_mode = true
        Rails.logger.error exception
        @_uc = nil
      end

      def error_status(e)
        Argu::ERROR_TYPES[e.class].try(:[], :status) || 400
      end

      def user_with_r(r)
        User.new(r: r, shortname: Shortname.new)
      end
    end
  end
end
