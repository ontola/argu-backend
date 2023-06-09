# frozen_string_literal: true

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:question, parent: freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'convert to motion' do
    ActsAsTenant.with_tenant(subject.root) do
      result = subject.convert_to(Motion)
      assert result[:new].is_a?(Motion)
      assert result[:old].is_a?(Question)
      assert_equal result[:new].display_name, result[:old].display_name
    end
  end

  test 'raise when converting to non-convertible class' do
    subject.convert_to(Argument)
    assert false
  rescue ArgumentError
    assert true
  end
end
