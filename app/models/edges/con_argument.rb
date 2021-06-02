# frozen_string_literal: true

class ConArgument < Argument
  paginates_per 5

  def option
    :no
  end

  def pro
    instance_variable_defined?('@pro') ? @pro : false
  end

  class << self
    def route_key
      :cons
    end
  end
end
