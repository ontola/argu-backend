# frozen_string_literal: true

module Opinionable
  module Action
    extend ActiveSupport::Concern

    included do
      has_action(
        :update_opinion,
        result: -> { opinion && "#{opinion.for.classify}Opinion".safe_constantize },
        type: -> { [NS::ARGU['Update::Opinion'], NS::SCHEMA[:UpdateAction]] },
        policy: :update?,
        http_method: :put,
        form: OpinionForm,
        url: -> { opinion&.iri },
        policy_resource: -> { opinion },
        condition: -> { opinion.present? }
      )
    end

    private

    def opinion
      @opinion ||= resource.opinion_for(user_context.user)
    end
  end
end
