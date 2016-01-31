module ProjectsHelper

  # Use this to get a string describing the phase's period.
  # TODO: Put into I18n and keep track of the tenses.
  def start_end_title_string(phase)
    [
      phase.start_date && "_starts on #{phase.start_date.strftime('%A, %B %d %Y')}",
      phase.end_date && "ends on #{phase.end_date.strftime('%A, %B %d %Y')}_"
    ].compact.join(' and ') || '_has no date set_'
  end
end
