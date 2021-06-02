# frozen_string_literal: true

class ProArgument < Argument
  paginates_per 5

  def option
    :yes
  end

  def pro
    instance_variable_defined?('@pro') ? @pro : true
  end

  class << self
    def route_key
      :pros
    end
  end
end
