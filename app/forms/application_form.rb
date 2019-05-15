# frozen_string_literal: true

class ApplicationForm < LinkedRails::Form
  extend UriTemplateHelper

  class << self
    private

    def actor_selector
      {
        custom: true,
        datatype: NS::XSD[:string],
        default_value: ->(resource) { resource.form.user_context.user.iri },
        max_count: 1,
        sh_in: ->(resource) { actors_iri(resource.form.target.root) }
      }
    end

    def mark_as_important_label(resource)
      I18n.t(
        'publications.follow_type.helper',
        news_audience: resource.parent.potential_audience(:news),
        reactions_audience: resource.parent.potential_audience(:reactions)
      )
    end
  end
end
