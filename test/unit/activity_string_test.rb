# frozen_string_literal: true

require 'test_helper'

class ActivityStringTest < ActiveSupport::TestCase
  define_freetown
  let(:updater) { create_initiator(freetown) }
  let(:receiver) { create_initiator(freetown) }
  let!(:question) { create(:question, parent: freetown) }
  let!(:motion) { create(:motion, parent: question) }
  let!(:approved_decision) do
    create(:decision,
           parent: motion,
           state: 'approved')
  end
  let!(:rejected_decision) do
    create(:decision,
           parent: motion,
           state: 'rejected')
  end
  let(:group) { create(:group, parent: argu) }
  let!(:forwarded_decision) do
    create(:decision,
           parent: motion,
           state: 'forwarded',
           forwarded_user_id: create(:group_membership, parent: group).member.profileable.id,
           forwarded_group_id: group.id)
  end

  test 'string for activities of question' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    assert_equal "[#{question.publisher.display_name}](#{question.publisher.iri}) "\
                  "posted a draft challenge in [#{freetown.display_name}](#{freetown.iri})",
                 Argu::ActivityString.new(create_activity, receiver, render: :embedded_link).to_s
    assert_equal "[#{updater.display_name}](#{updater.iri}) "\
                  "updated [#{question.display_name}](#{question.iri})",
                 Argu::ActivityString.new(update_activity, receiver, render: :embedded_link).to_s
    assert_equal "[#{updater.display_name}](#{updater.iri}) "\
                  "trashed [#{question.display_name}](#{question.iri})",
                 Argu::ActivityString.new(trash_activity, receiver, render: :embedded_link).to_s
  end

  test 'string for activities of question with interpolation' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    assert_equal '{{https://www.w3.org/ns/activitystreams#actor}} '\
                  'posted a draft challenge in {{https://www.w3.org/ns/activitystreams#target}}',
                 Argu::ActivityString.new(create_activity, receiver, render: :template).to_s
    assert_equal '{{https://www.w3.org/ns/activitystreams#actor}} '\
                  'updated {{https://www.w3.org/ns/activitystreams#object}}',
                 Argu::ActivityString.new(update_activity, receiver, render: :template).to_s
    assert_equal '{{https://www.w3.org/ns/activitystreams#actor}} '\
                  'trashed {{https://www.w3.org/ns/activitystreams#object}}',
                 Argu::ActivityString.new(trash_activity, receiver, render: :template).to_s
  end

  test 'string for activities of deleted question' do
    display_name = question.display_name
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    destroy_resource(question, updater)
    destroy_activity = Activity.last
    assert_equal "[#{question.publisher.display_name}](#{question.publisher.iri}) "\
                  "posted a draft challenge in [#{freetown.display_name}](#{freetown.iri})",
                 Argu::ActivityString.new(create_activity.reload, receiver, render: :embedded_link).to_s
    assert_equal "[#{updater.display_name}](#{updater.iri}) "\
                  "updated #{display_name}",
                 Argu::ActivityString.new(update_activity.reload, receiver, render: :embedded_link).to_s
    assert_equal "[#{updater.display_name}](#{updater.iri}) "\
                  "trashed #{display_name}",
                 Argu::ActivityString.new(trash_activity.reload, receiver, render: :embedded_link).to_s
    assert_equal "[#{updater.display_name}](#{updater.iri}) "\
                  "deleted #{display_name}",
                 Argu::ActivityString.new(destroy_activity.reload, receiver, render: :embedded_link).to_s
  end

  test 'string for activities of motion of deleted question' do
    display_name = motion.display_name
    create_activity = motion.activities.first
    update_activity = update_resource(motion, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(motion, updater).activities.last
    destroy_resource(question)
    assert_equal "[#{motion.publisher.display_name}](#{motion.publisher.iri}) "\
                  "posted a draft idea in #{question.display_name}",
                 Argu::ActivityString.new(create_activity.reload, receiver, render: :embedded_link).to_s
    assert_equal "[#{updater.display_name}](#{updater.iri}) "\
                  "updated #{display_name}",
                 Argu::ActivityString.new(update_activity.reload, receiver, render: :embedded_link).to_s
    assert_equal "[#{updater.display_name}](#{updater.iri}) "\
                  "trashed #{display_name}",
                 Argu::ActivityString.new(trash_activity.reload, receiver, render: :embedded_link).to_s
  end

  test 'string for activities of question by deleted user' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, question.publisher).activities.last
    trash_activity = trash_resource(question, question.publisher).activities.last
    question.publisher.destroy
    assert_equal "community posted a draft challenge in [#{freetown.display_name}](#{freetown.iri})",
                 Argu::ActivityString.new(create_activity.reload, receiver, render: :embedded_link).to_s
    assert_equal "community updated [#{question.display_name}](#{question.iri})",
                 Argu::ActivityString.new(update_activity.reload, receiver, render: :embedded_link).to_s
    assert_equal "community trashed [#{question.display_name}](#{question.iri})",
                 Argu::ActivityString.new(trash_activity.reload, receiver, render: :embedded_link).to_s
  end

  test 'string for approved decision' do
    approved_activity = approved_decision.activities.second
    assert_equal "[#{approved_decision.publisher.display_name}](#{approved_decision.publisher.iri}) "\
                  "passed [#{motion.display_name}](#{motion.iri})",
                 Argu::ActivityString.new(approved_activity, receiver, render: :embedded_link).to_s
  end

  test 'string for rejected decision' do
    rejected_activity = rejected_decision.activities.second
    assert_equal "[#{rejected_decision.publisher.display_name}](#{rejected_decision.publisher.iri}) "\
                  "rejected [#{motion.display_name}](#{motion.iri})",
                 Argu::ActivityString.new(rejected_activity, receiver, render: :embedded_link).to_s
  end

  test 'string for forwarded decision' do
    forwarded_activity = forwarded_decision.activities.second
    assert_equal "[#{forwarded_decision.publisher.display_name}](#{forwarded_decision.publisher.iri}) "\
                  "forwarded the decision on [#{motion.display_name}](#{motion.iri})",
                 Argu::ActivityString.new(forwarded_activity, receiver, render: :embedded_link).to_s
  end

  test 'string for forwarded decision to you' do
    forwarded_activity = forwarded_decision.activities.second
    assert_equal "[#{forwarded_decision.publisher.display_name}](#{forwarded_decision.publisher.iri}) "\
                  "forwarded the decision on [#{motion.display_name}](#{motion.iri}) to you",
                 Argu::ActivityString.new(forwarded_activity, motion.assigned_user, render: :embedded_link).to_s
  end

  test 'string for updated decision' do
    update_activity = update_resource(approved_decision, {content: 'updated content'}, updater).activities.last
    assert_equal "[#{updater.display_name}](#{updater.iri}) "\
                  "updated a decision on [#{motion.display_name}](#{motion.iri})",
                 Argu::ActivityString.new(update_activity, receiver, render: :embedded_link).to_s
  end
end
