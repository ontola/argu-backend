# frozen_string_literal: false
module TimelineHelper
  def generate_phase_link_class(project, phase)
    class_string = 'timeline-phase-title tooltip--top'
    class_string << ' finished' if project.current_phase.present? && phase.id < project.current_phase.id
    class_string << ' current' if project.current_phase.present? && phase == project.current_phase
    class_string
  end

  def generate_timeline_point_class(happening, active)
    class_string = 'tooltip--side-right timeline-point'
    class_string << " timeline-point-#{happening.trackable.model_name.singular.dasherize}"
    class_string << ' unpublished' unless happening.trackable.is_published
    class_string << ' active' if active
    class_string
  end

  def render_timeline?(resource, show_unpublished)
    resource.happenings.published(show_unpublished).count > 1 ||
      resource.respond_to?(:phases) && resource.phases.present?
  end

  # Use this to get a string describing the phase's period.
  # TODO: Put into I18n and keep track of the tenses.
  def start_end_title_string(phase)
    [
      phase.start_date && "_starts on #{phase.start_date.strftime('%A, %B %d %Y')}",
      phase.end_date && "ends on #{phase.end_date.strftime('%A, %B %d %Y')}_"
    ].compact.join(' and ') || '_has no date set_'
  end

  def start_end_title_short_string(phase)
    [
      phase.start_date && l(phase.start_date, format: :date).to_s,
      phase.end_date && l(phase.end_date, format: :date).to_s
    ].compact.join(' - ')
  end
end
