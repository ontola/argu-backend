# frozen_string_literal: true

class SurveyActionList < EdgeActionList
  has_action(
    :create_submission,
    result: Submission,
    type: -> { [NS::ARGU[:SubmitAction]] },
    policy: :create_child?,
    policy_resource: -> { resource.submission_collection },
    url: -> { collection_iri(resource, :submissions) },
    http_method: :post,
    favorite: true
  )
end
