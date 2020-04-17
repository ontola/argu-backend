# frozen_string_literal: true

module Opinionable
  module Action
    extend ActiveSupport::Concern

    included do
      has_action(
        :update_opinion,
        result: -> { opinion && vote.opinion_class.safe_constantize },
        type: -> { [NS::ARGU['Update::Opinion'], NS::SCHEMA[:UpdateAction]] },
        policy: :update?,
        http_method: :put,
        form: OpinionForm,
        url: -> { opinion&.iri },
        resource: -> { opinion },
        condition: -> { opinion.present? },
        root_relative_iri: lambda {
          iri_template_expand_path(resource.send(:iri_template), '/actions/update_opinion').expand(resource.iri_opts)
        }
      )
    end

    private

    def opinion
      @opinion ||= resource.opinion_for(user_context.user)
    end

    def vote
      @vote ||= resource.vote_for(user_context.user)
    end
  end
end
