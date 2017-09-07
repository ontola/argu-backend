# frozen_string_literal: true

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
            verdict: verdict
          )
        end

        true
      end
    end

    def authorize(record, query = nil, opts = [], outside_tree: false)
      query ||= params[:action].to_s + '?'

      @_pundit_policy_authorized = true

      policy = policy(record)
      policy.outside_tree = true if outside_tree

      unless policy.public_send(query, *opts)
        raise NotAuthorizedError.new(
          query: query,
          record: record,
          policy: policy,
          verdict: policy.last_verdict
        )
      end

      true
    end
  end
end
