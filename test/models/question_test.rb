# frozen_string_literal: true

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:question, parent: freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'convert to motion' do
    result = subject.convert_to(Motion)
    assert result[:new].is_a?(Motion)
    assert result[:old].is_a?(Question)
    assert_equal result[:new].display_name, result[:old].display_name
  end

  test 'raise when converting to non-convertible class' do
    begin
      subject.convert_to(Argument)
    rescue ArgumentError
      assert true
    else
      assert_not true
    end
  end
end
