require 'argu/not_authorized_error'

module Argu
  module RuledIt
    extend ActiveSupport::Concern
    include Pundit

    class << self
      def authorize(user, record, query)
        policy = policy!(user, record)

        authorized, verdict = policy.public_send(query)
        unless authorized
          raise Argu::NotAuthorizedError.new(
            query: query,
            record: record,
            policy: policy,
            verdict: verdict)
        end

        true
      end
    end

    def authorize(record, query = nil)
      query ||= params[:action].to_s + '?'

      @_pundit_policy_authorized = true

      policy = policy(record)
      unless policy.public_send(query)
        raise NotAuthorizedError.new(
          query: query,
          record: record,
          policy: policy,
          verdict: policy.last_verdict)
      end

      true
    end
  end
end
