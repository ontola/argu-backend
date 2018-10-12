# frozen_string_literal: true

require 'argu/errors/forbidden'

module Argu
  module RuledIt
    extend ActiveSupport::Concern
    include Pundit

    class << self
      def authorize(user, record, query)
        policy = policy!(user, record)

        unless policy.public_send(query)
          raise Argu::Errors::Forbidden.new(
            query: query,
            record: record,
            policy: policy,
            message: policy.try(:message)
          )
        end

        true
      end
    end

    def authorize(record, query = nil, opts = [])
      query ||= params[:action].to_s + '?'

      @_pundit_policy_authorized = true

      policy = policy(record)

      unless policy.public_send(query, *opts)
        raise Argu::Errors::Forbidden.new(
          query: query,
          record: record,
          policy: policy,
          message: policy.try(:message)
        )
      end

      true
    end
  end
end
