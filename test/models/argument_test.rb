require 'test_helper'

class ArgumentTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:argument) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

end
