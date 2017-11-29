# frozen_string_literal: true

module Argu
  module Errors
    class NotAuthorized < Pundit::Error
      attr_reader :query, :record, :policy, :action

      # @param [Hash] options
      # @option options [String] query The action of the request
      # @option options [ActiveRecord::Base] record The record that was requested
      # @option options [Policy] policy The policy that raised the exception
      # @return [String] the message
      def initialize(options = {})
        @query  = options.fetch(:query)
        @record = options[:record]
        @policy = options[:policy]
        @action = @query.to_s[0..-2]

        raise StandardError if @query.blank?

        message = I18n.t("pundit.#{@policy.class.to_s.underscore}.#{@query}",
                         action: @action,
                         default: I18n.t('access_denied'))
        super(message)
      end
    end
  end
end
