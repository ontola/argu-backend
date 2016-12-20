# frozen_string_literal: true
require 'test_helper'

class ActivityStringTest < ActiveSupport::TestCase
  define_freetown
  let(:updater) { create_member(freetown) }
  let(:receiver) { create_member(freetown) }
  let!(:project) do
    create(:project,
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}},
           parent: freetown.edge)
  end
  let!(:question) { create(:question, parent: project.edge) }
  let!(:motion) { create(:motion, parent: question.edge) }
  let!(:approved_decision) do
    create(:decision,
           parent: motion.edge,
           state: 'approved',
           happening_attributes: {happened_at: DateTime.current},
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}})
  end
  let!(:rejected_decision) do
    create(:decision,
           parent: motion.edge,
           state: 'rejected',
           happening_attributes: {happened_at: DateTime.current},
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}})
  end
  let(:group) { create(:group, parent: freetown.page.edge) }
  let!(:forwarded_decision) do
    create(:decision,
           parent: motion.edge,
           state: 'forwarded',
           happening_attributes: {happened_at: DateTime.current},
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}},
           forwarded_user_id: create(:group_membership, parent: group.edge).member.profileable,
           forwarded_group_id: group.id)
  end

  test 'string for activities of question' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    assert_equal "[#{question.publisher.display_name}](/u/#{question.publisher.url}) "\
                  "posted a challenge in [#{project.display_name}](/p/#{project.id})",
                 Argu::ActivityString.new(create_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "updated [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(update_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "trashed [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(trash_activity, receiver, true).to_s
  end

  test 'string for activities of deleted question' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    destroy_resource(question, updater)
    destroy_activity = Activity.last
    assert_equal "[#{question.publisher.display_name}](/u/#{question.publisher.url}) "\
                  "posted a challenge in [#{project.display_name}](/p/#{project.id})",
                 Argu::ActivityString.new(create_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "updated #{question.display_name}",
                 Argu::ActivityString.new(update_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "trashed #{question.display_name}",
                 Argu::ActivityString.new(trash_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "deleted #{question.display_name}",
                 Argu::ActivityString.new(destroy_activity, receiver, true).to_s
  end

  test 'string for activities of question with deleted parent' do
    destroy_resource(project)
    question.reload
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    assert_equal "[#{question.publisher.display_name}](/u/#{question.publisher.url}) "\
                  "posted a challenge in #{project.display_name}",
                 Argu::ActivityString.new(create_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "updated [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(update_activity, receiver, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "trashed [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(trash_activity, receiver, true).to_s
  end

  test 'string for activities of question by deleted user' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, question.publisher).activities.last
    trash_activity = trash_resource(question, question.publisher).activities.last
    question.publisher.destroy
    assert_equal "#{question.publisher.display_name} "\
                  "posted a challenge in [#{project.display_name}](/p/#{project.id})",
                 Argu::ActivityString.new(create_activity.reload, receiver, true).to_s
    assert_equal "#{question.publisher.display_name} "\
                  "updated [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(update_activity.reload, receiver, true).to_s
    assert_equal "#{question.publisher.display_name} "\
                  "trashed [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(trash_activity.reload, receiver, true).to_s
  end

  test 'string for approved decision' do
    approved_activity = approved_decision.activities.second
    assert_equal "[#{approved_decision.publisher.display_name}](/u/#{approved_decision.publisher.url}) "\
                  "passed [#{motion.display_name}](/m/#{motion.id})",
                 Argu::ActivityString.new(approved_activity, receiver, true).to_s
  end

  test 'string for rejected decision' do
    rejected_activity = rejected_decision.activities.second
    assert_equal "[#{rejected_decision.publisher.display_name}](/u/#{rejected_decision.publisher.url}) "\
                  "rejected [#{motion.display_name}](/m/#{motion.id})",
                 Argu::ActivityString.new(rejected_activity, receiver, true).to_s
  end

  test 'string for forwarded decision' do
    forwarded_activity = forwarded_decision.activities.second
    assert_equal "[#{forwarded_decision.publisher.display_name}](/u/#{forwarded_decision.publisher.url}) "\
                  "forwarded the decision on [#{motion.display_name}](/m/#{motion.id})",
                 Argu::ActivityString.new(forwarded_activity, receiver, true).to_s
  end

  test 'string for forwarded decision to you' do
    forwarded_activity = forwarded_decision.activities.second
    assert_equal "[#{forwarded_decision.publisher.display_name}](/u/#{forwarded_decision.publisher.url}) "\
                  "forwarded the decision on [#{motion.display_name}](/m/#{motion.id}) to you",
                 Argu::ActivityString.new(forwarded_activity, motion.assigned_user, true).to_s
  end

  test 'string for updated decision' do
    update_activity = update_resource(approved_decision, {content: 'updated content'}, updater).activities.last
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "updated a decision on [#{motion.display_name}](/m/#{motion.id})",
                 Argu::ActivityString.new(update_activity, receiver, true).to_s
  end
end
