# frozen_string_literal: true

class EmploymentModerationsController < EmploymentsController
  private

  def edge_from_opts(opts)
    if uuid?(opts[:id])
      EmploymentModeration.find_by(uuid: opts[:id])
    else
      EmploymentModeration.find_by(fragment: opts[:id])
    end
  end
end
