module ProjectsHelper

  def start_end_title_string(phase)
    [
      phase.start_date && "_starts on #{phase.start_date.strftime('%A, %B %d %Y')}",
      phase.end_date && "ends on #{phase.end_date.strftime('%A, %B %d %Y')}_"
    ].compact.join(' and ') || '_has no date set_'
  end
end
