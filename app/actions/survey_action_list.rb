# frozen_string_literal: true

class SurveyActionList < EdgeActionList
  has_resource_action(
    :create_submission,
    result: Submission,
    type: -> { [NS.argu[:SubmitAction]] },
    policy: :create_child?,
    policy_resource: -> { resource.submission_collection(user_context: user_context) },
    url: -> { collection_iri(resource, :submissions) },
    http_method: :post,
    favorite: true
  )
end
