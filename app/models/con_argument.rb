# frozen_string_literal: true

class ConArgument < Argument
  # To facilitate the group_by command
  def key
    :con
  end

  def pro
    instance_variable_defined?('@pro') ? @pro : false
  end
end
