
require 'test_helper'
class MotionTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:motion, :with_arguments) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'top_arguments_con_light should not include trashed motions' do
    trashed_args = subject.arguments.where(is_trashed: true).pluck(:id)
    assert trashed_args.present?,
           'No trashed arguments exist, test is useless'
    assert_not (subject.top_arguments_con_light.map { |i| i[0] } & trashed_args).present?
  end

  test 'top_arguments_pro_light should not include trashed motions' do
    trashed_args = subject.arguments.where(is_trashed: true).pluck(:id)
    assert trashed_args.present?,
           'No trashed arguments exist, test is useless'
    assert_not (subject.top_arguments_con_light.map { |i| i[0] } & trashed_args).present?
  end

  test 'should update to correct interactions count' do
    assert_equal 20, subject.interactions_count
    FactoryGirl.create(:vote, voteable: subject, for: Vote.fors[:pro])
    FactoryGirl.create(:vote, voteable: subject, for: Vote.fors[:con])
    FactoryGirl.create(:vote, voteable: subject, for: Vote.fors[:con])
    FactoryGirl.create(:vote, voteable: subject, for: Vote.fors[:neutral])
    assert_equal 24, subject.interactions_count
    argument = subject.arguments.first
    argument.votes.create(for: Vote.fors[:pro], forum: subject.forum, voter: create(:profile))
    argument.votes.create(for: Vote.fors[:pro], forum: subject.forum, voter: create(:profile))
    argument.votes.create(for: Vote.fors[:pro], forum: subject.forum, voter: create(:profile))
    assert_equal 27, subject.reload.interactions_count
  end
end
