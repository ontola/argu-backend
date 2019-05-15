# frozen_string_literal: true

module Opinionable
  module Action
    extend ActiveSupport::Concern

    included do
      has_action(
        :update_opinion,
        result: -> { "#{resource.vote_for(user_context.user).for.classify}Opinion".safe_constantize },
        type: -> { [NS::ARGU['Update::Opinion'], NS::SCHEMA[:UpdateAction]] },
        policy: :update?,
        http_method: :put,
        form: OpinionForm,
        url: -> { resource.opinion_for(user_context.user)&.iri },
        policy_resource: -> { resource.opinion_for(user_context.user) },
        condition: -> { resource.opinion_for(user_context.user).present? }
      )
    end
  end
end
