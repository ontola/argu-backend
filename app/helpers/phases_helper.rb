# frozen_string_literal: true

# Helper methods for decisions
module PhasesHelper
  # @return [String]
  def phase_start_date_origin(phase)
    if phase.start_date == phase.project.start_date
      t('projects.phases.start_date.from_project')
    else
      t('projects.phases.start_date.from_previous_phase')
    end
  end
end
