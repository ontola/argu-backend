# frozen_string_literal: true

class ApplicationForm < RailsLD::Form
  class << self
    private

    def mark_as_important_label(resource)
      I18n.t(
        'publications.follow_type.helper',
        news_audience: resource.parent.potential_audience(:news),
        reactions_audience: resource.parent.potential_audience(:reactions)
      )
    end
  end
end
