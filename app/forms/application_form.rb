# frozen_string_literal: true

class ApplicationForm < LinkedRails::Form
  include UriTemplateHelper
  include VisibilityHelper

  private

  def mark_as_important_label(resource)
    I18n.t(
      'publications.follow_type.helper',
      news_audience: resource.parent.potential_audience(:news),
      reactions_audience: resource.parent.potential_audience(:reactions)
    )
  end

  class << self
    private

    def actor_selector
      {
        custom: true,
        datatype: NS::XSD[:string],
        default_value: -> { user_context.user.iri },
        max_count: 1,
        sh_in: -> { actors_iri(target.root) }
      }
    end

    def visibility_text
      resource visibility_text: {
        description: -> { visible_for_string(target) },
        if: -> { target.new_record? }
      }
    end
  end
end
