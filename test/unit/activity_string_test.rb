# frozen_string_literal: true
require 'test_helper'

class ActivityStringTest < ActiveSupport::TestCase
  define_freetown
  let(:updater) { create_member(freetown) }
  let(:receiver) { create_member(freetown) }
  let!(:project) do
    create(:project,
           parent: freetown.edge)
  end
  let!(:question) { create(:question, parent: project.edge) }
  let!(:motion) { create(:motion, parent: question.edge) }
  let!(:approved_decision) do
    create(:decision,
           parent: motion.edge,
           state: 'approved',
           happening_attributes: {happened_at: DateTime.current})
  end
  let!(:rejected_decision) do
    create(:decision,
           parent: motion.edge,
           state: 'rejected',
           happening_attributes: {happened_at: DateTime.current})
  end
  let(:group) { create(:group, parent: freetown.page.edge) }
  let!(:forwarded_decision) do
    create(:decision,
           parent: motion.edge,
           state: 'forwarded',
           happening_attributes: {happened_at: DateTime.current},
           forwarded_user_id: create(:group_membership, parent: group).member.profileable,
           forwarded_group_id: group.id)
  end

  test 'string for activities of question' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    assert_equal "[#{question.publisher.display_name}](#{url("/u/#{question.publisher.url}")}) "\
                  "posted a draft challenge in [#{project.display_name}](#{url("/p/#{project.id}")})",
                 Argu::ActivityString.new(create_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](#{url("/u/#{updater.url}")}) "\
                  "updated [#{question.display_name}](#{url("/q/#{question.id}")})",
                 Argu::ActivityString.new(update_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](#{url("/u/#{updater.url}")}) "\
                  "trashed [#{question.display_name}](#{url("/q/#{question.id}")})",
                 Argu::ActivityString.new(trash_activity, receiver, true).to_s
  end

  test 'string for activities of deleted question' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    destroy_resource(question, updater)
    destroy_activity = Activity.last
    assert_equal "[#{question.publisher.display_name}](#{url("/u/#{question.publisher.url}")}) "\
                  "posted a draft challenge in [#{project.display_name}](#{url("/p/#{project.id}")})",
                 Argu::ActivityString.new(create_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](#{url("/u/#{updater.url}")}) "\
                  "updated #{question.display_name}",
                 Argu::ActivityString.new(update_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](#{url("/u/#{updater.url}")}) "\
                  "trashed #{question.display_name}",
                 Argu::ActivityString.new(trash_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](#{url("/u/#{updater.url}")}) "\
                  "deleted #{question.display_name}",
                 Argu::ActivityString.new(destroy_activity, receiver, true).to_s
  end

  test 'string for activities of question with deleted parent' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    destroy_resource(project)
    assert_equal "[#{question.publisher.display_name}](#{url("/u/#{question.publisher.url}")}) "\
                  "posted a draft challenge in #{project.display_name}",
                 Argu::ActivityString.new(create_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](#{url("/u/#{updater.url}")}) "\
                  "updated #{question.display_name}",
                 Argu::ActivityString.new(update_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](#{url("/u/#{updater.url}")}) "\
                  "trashed #{question.display_name}",
                 Argu::ActivityString.new(trash_activity, receiver, true).to_s
  end

  test 'string for activities of question by deleted user' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, question.publisher).activities.last
    trash_activity = trash_resource(question, question.publisher).activities.last
    question.publisher.destroy
    assert_equal "community posted a draft challenge in [#{project.display_name}](#{url("/p/#{project.id}")})",
                 Argu::ActivityString.new(create_activity.reload, receiver, true).to_s
    assert_equal "community updated [#{question.display_name}](#{url("/q/#{question.id}")})",
                 Argu::ActivityString.new(update_activity.reload, receiver, true).to_s
    assert_equal "community trashed [#{question.display_name}](#{url("/q/#{question.id}")})",
                 Argu::ActivityString.new(trash_activity.reload, receiver, true).to_s
  end

  test 'string for approved decision' do
    approved_activity = approved_decision.activities.second
    assert_equal "[#{approved_decision.publisher.display_name}](#{url("/u/#{approved_decision.publisher.url}")}) "\
                  "passed [#{motion.display_name}](#{url("/m/#{motion.id}")})",
                 Argu::ActivityString.new(approved_activity, receiver, true).to_s
  end

  test 'string for rejected decision' do
    rejected_activity = rejected_decision.activities.second
    assert_equal "[#{rejected_decision.publisher.display_name}](#{url("/u/#{rejected_decision.publisher.url}")}) "\
                  "rejected [#{motion.display_name}](#{url("/m/#{motion.id}")})",
                 Argu::ActivityString.new(rejected_activity, receiver, true).to_s
  end

  test 'string for forwarded decision' do
    forwarded_activity = forwarded_decision.activities.second
    assert_equal "[#{forwarded_decision.publisher.display_name}](#{url("/u/#{forwarded_decision.publisher.url}")}) "\
                  "forwarded the decision on [#{motion.display_name}](#{url("/m/#{motion.id}")})",
                 Argu::ActivityString.new(forwarded_activity, receiver, true).to_s
  end

  test 'string for forwarded decision to you' do
    forwarded_activity = forwarded_decision.activities.second
    assert_equal "[#{forwarded_decision.publisher.display_name}](#{url("/u/#{forwarded_decision.publisher.url}")}) "\
                  "forwarded the decision on [#{motion.display_name}](#{url("/m/#{motion.id}")}) to you",
                 Argu::ActivityString.new(forwarded_activity, motion.assigned_user, true).to_s
  end

  test 'string for updated decision' do
    update_activity = update_resource(approved_decision, {content: 'updated content'}, updater).activities.last
    assert_equal "[#{updater.display_name}](#{url("/u/#{updater.url}")}) "\
                  "updated a decision on [#{motion.display_name}](#{url("/m/#{motion.id}")})",
                 Argu::ActivityString.new(update_activity, receiver, true).to_s
  end

  private

  def url(u)
    "http://#{Rails.application.config.host_name}#{u}"
  end
end
