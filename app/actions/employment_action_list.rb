# frozen_string_literal: true

class EmploymentActionList < EdgeActionList
  has_action(
    :confirm,
    policy: :update?,
    type: NS::ARGU[:ConfirmAction],
    image: 'fa-check',
    http_method: :put,
    root_relative_iri: lambda {
      "/moderation/#{resource.fragment}/actions/confirm"
    },
    url: -> { RDF::URI("#{resource.iri}?employment[validated]=true") }
  )
end
