# frozen_string_literal: true

class ConArgument < Argument
  paginates_per 5

  # To facilitate the group_by command
  def key
    :con
  end

  def pro
    instance_variable_defined?('@pro') ? @pro : false
  end
end
