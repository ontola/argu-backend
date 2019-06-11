# frozen_string_literal: true

class CommentActionList < EdgeActionList
  has_action(
    :create_opinion,
    result: lambda {
      "#{resource.parent.ancestor(:motion)&.vote_for(user_context.user)&.for&.classify}Opinion".safe_constantize
    },
    type: -> { [NS::ARGU['Create::Opinion'], NS::SCHEMA[:CreateAction]] },
    policy: :create_opinion?,
    http_method: :post,
    form: OpinionForm,
    collection: true,
    url: -> { collection_iri(resource.parent, :comments) },
    condition: lambda {
      resource.parent.is_a?(Motion) &&
        resource.parent.vote_for(user_context.user)&.present? &&
        resource.parent.opinion_for(user_context.user).blank?
    }
  )
end
