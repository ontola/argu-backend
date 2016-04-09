require 'test_helper'

class MotionTest < ActiveSupport::TestCase
  subject { create(:motion, :with_arguments) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'top_arguments_con_light should not include trashed motions' do
    trashed_args = subject.arguments.where(is_trashed: true).pluck(:id)
    assert trashed_args.present?,
           'No trashed arguments exist, test is useless'
    assert_not(subject.top_arguments_con_light.map { |i| i[0] } & trashed_args).present?
  end

  test 'top_arguments_pro_light should not include trashed motions' do
    trashed_args = subject.arguments.where(is_trashed: true).pluck(:id)
    assert trashed_args.present?,
           'No trashed arguments exist, test is useless'
    assert_not(subject.top_arguments_con_light.map { |i| i[0] } & trashed_args).present?
  end
end
