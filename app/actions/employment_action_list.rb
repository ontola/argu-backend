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
    url: -> { RDF::URI("#{resource.iri}?employment_moderation[validated]=true") }
  )
  has_action(
    :destroy,
    destroy_options.merge(
      description: lambda {
        count = resource.submitted_interventions.count
        if count.positive?
          I18n.t('actions.employment_moderations.destroy.description.with_count', intervention_count: count)
        else
          I18n.t('actions.employment_moderations.destroy.description.none')
        end
      }
    )
  )
end
