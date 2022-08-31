# frozen_string_literal: true

require 'test_helper'

class ActivityStringTest < ActiveSupport::TestCase
  define_freetown
  let(:updater) { create_initiator(freetown) }
  let(:receiver) { create_initiator(freetown) }
  let!(:question) { create(:question, parent: freetown) }
  let!(:motion) { create(:motion, parent: question) }
  let(:group) { create(:group, parent: argu) }

  test 'string for activities of question' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    assert_equal "#{question.publisher.display_name} "\
                 "posted a draft challenge in #{freetown.display_name}",
                 Argu::ActivityString.new(create_activity, receiver, render: :display_name).to_s
    assert_equal "#{updater.display_name} "\
                 "updated #{question.display_name}",
                 Argu::ActivityString.new(update_activity, receiver, render: :display_name).to_s
    assert_equal "#{updater.display_name} "\
                 "trashed #{question.display_name}",
                 Argu::ActivityString.new(trash_activity, receiver, render: :display_name).to_s
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
    assert_equal "#{question.publisher.display_name} "\
                 "posted a draft challenge in #{freetown.display_name}",
                 Argu::ActivityString.new(create_activity.reload, receiver, render: :display_name).to_s
    assert_equal "#{updater.display_name} "\
                 "updated #{display_name}",
                 Argu::ActivityString.new(update_activity.reload, receiver, render: :display_name).to_s
    assert_equal "#{updater.display_name} "\
                 "trashed #{display_name}",
                 Argu::ActivityString.new(trash_activity.reload, receiver, render: :display_name).to_s
    assert_equal "#{updater.display_name} "\
                 "deleted #{display_name}",
                 Argu::ActivityString.new(destroy_activity.reload, receiver, render: :display_name).to_s
  end

  test 'string for activities of motion of deleted question' do
    display_name = motion.display_name
    create_activity = motion.activities.first
    update_activity = update_resource(motion, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(motion, updater).activities.last
    destroy_resource(question)
    assert_equal "#{motion.publisher.display_name} "\
                 "posted a draft idea in #{question.display_name}",
                 Argu::ActivityString.new(create_activity.reload, receiver, render: :display_name).to_s
    assert_equal "#{updater.display_name} "\
                 "updated #{display_name}",
                 Argu::ActivityString.new(update_activity.reload, receiver, render: :display_name).to_s
    assert_equal "#{updater.display_name} "\
                 "trashed #{display_name}",
                 Argu::ActivityString.new(trash_activity.reload, receiver, render: :display_name).to_s
  end

  test 'string for activities of question by deleted user' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, question.publisher).activities.last
    trash_activity = trash_resource(question, question.publisher).activities.last
    question.publisher.destroy
    assert_equal "community posted a draft challenge in #{freetown.display_name}",
                 Argu::ActivityString.new(create_activity.reload, receiver, render: :display_name).to_s
    assert_equal "community updated #{question.display_name}",
                 Argu::ActivityString.new(update_activity.reload, receiver, render: :display_name).to_s
    assert_equal "community trashed #{question.display_name}",
                 Argu::ActivityString.new(trash_activity.reload, receiver, render: :display_name).to_s
  end
end
