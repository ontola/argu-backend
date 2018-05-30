# frozen_string_literal: false

module TimelineHelper
  def current_happening(happenings)
    if params[:happening_id].present?
      happenings.detect { |happening| happening.id.to_i == params[:happening_id].to_i }
    else
      happenings.last
    end
  end

  def generate_timeline_point_class(happening, active)
    class_string = 'tooltip--side-right timeline-point'
    class_string << " timeline-point-#{happening.trackable.model_name.singular.dasherize}"
    class_string << ' unpublished' unless happening.trackable.is_published
    class_string << ' active' if active
    class_string
  end
end
