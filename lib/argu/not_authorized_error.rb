# frozen_string_literal: true
module Argu
  class NotAuthorizedError < Pundit::Error
    attr_reader :query, :record, :policy, :verdict, :action

    # @param [Hash] options
    # @option options [String] query The action of the request
    # @option options [ActiveRecord::Base] record The record that was requested
    # @option options [Policy] policy The policy that raised the exception
    # @option options [String] verdict Reason to deny authorisation
    # @return [String] the message
    def initialize(options = {})
      @query  = options.fetch(:query)
      @record = options[:record]
      @policy = options[:policy]
      @verdict = options[:verdict]
      @action = @query.to_s[0..-2]

      raise StandardError unless @query.present?

      message = @verdict || I18n.t("pundit.#{@policy.class.to_s.underscore}.#{@query}",
                                   action: @action,
                                   default: I18n.t('access_denied'))
      super(message)
    end
  end
end
