require 'test_helper'

class MotionTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:motion, :with_arguments) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'top_arguments_con_light should not include trashed motions' do
    assert subject.arguments.where(is_trashed: true).present?, 'No trashed arguments exist, test is useless'
    assert_not subject.top_arguments_con_light.map { |i| i[0] }.include?(arguments(:trashed_con).id)
  end

  test 'top_arguments_pro_light should not include trashed motions' do
    assert subject.arguments.where(is_trashed: true).present?, 'No trashed arguments exist, test is useless'
    assert_not subject.top_arguments_con_light.map { |i| i[0] }.include?(arguments(:trashed).id)
  end
end
