require "test_helper"

class ArgumentTest < ActiveSupport::TestCase

  def argument
    @argument ||= arguments(:one)
  end

  def test_valid
    assert argument.valid?, argument.errors.to_a.join(',').to_s
  end

end
