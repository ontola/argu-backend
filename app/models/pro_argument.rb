# frozen_string_literal: true

class ProArgument < Argument
  paginates_per 5

  # To facilitate the group_by command
  def key
    :pro
  end

  def pro
    instance_variable_defined?('@pro') ? @pro : true
  end
end
