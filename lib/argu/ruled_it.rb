module Argu
  module RuledIt
    extend ActiveSupport::Concern
    include Pundit

    class NotAuthorizedError < Pundit::Error
      attr_reader :query, :record, :policy, :verdict

      def initialize(options = {})
        if options.is_a? String
          message = options
        else
          @query  = options[:query]
          @record = options[:record]
          @policy = options[:policy]
          @verdict = options[:verdict]

          message = options.fetch(:message) { "not allowed to #{query} this #{record.inspect}" }
        end

        super(message)
      end
    end

    class << self
      def authorize(user, record, query)
        policy = policy!(user, record)

        authorized, verdict = policy.public_send(query)
        unless authorized
          raise NotAuthorizedError.new(
            query: query,
            record: record,
            policy: policy,
            verdict: verdict)
        end

        true
      end

    end

    def authorize(record, query=nil)
      query ||= params[:action].to_s + '?'

      @_pundit_policy_authorized = true

      policy = policy(record)
      authorized, verdict = policy.public_send(query)
      unless authorized
        raise NotAuthorizedError.new(
          query: query,
          record: record,
          policy: policy,
          verdict: verdict)
      end

      true
    end

  end
end
