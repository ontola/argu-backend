# frozen_string_literal: true

require 'test_helper'

class MotionTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:motion, :with_arguments, parent: freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'active_arguments_con should not include trashed motions' do
    trashed_args = subject.arguments.trashed.pluck(:id)
    assert trashed_args.present?,
           'No trashed arguments exist, test is useless'
    assert_not((subject.active_con_arguments.map(&:id) & trashed_args).present?)
  end

  test 'active_arguments_pro should not include trashed motions' do
    trashed_args = subject.arguments.trashed.pluck(:id)
    assert trashed_args.present?,
           'No trashed arguments exist, test is useless'
    assert_not((subject.active_pro_arguments.map(&:id) & trashed_args).present?)
  end

  test 'convert to question' do
    result = subject.convert_to(Question)
    assert result[:new].is_a?(Question)
    assert result[:old].is_a?(Motion)
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
