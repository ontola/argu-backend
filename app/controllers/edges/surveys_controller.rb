# frozen_string_literal: true

class SurveysController < EdgeableController
  has_resource_action(
    :create_submission,
    favorite: true,
    http_method: :post,
    policy: :create_child?,
    policy_resource: -> { resource.submission_collection(user_context: user_context) },
    result: Submission,
    target_url: -> { collection_iri(resource, :submissions) },
    type: -> { [NS.argu[:SubmitAction]] }
  )
end
