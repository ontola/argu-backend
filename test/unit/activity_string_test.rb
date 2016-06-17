require 'test_helper'

class ActivityStringTest < ActiveSupport::TestCase
  let!(:freetown) { create(:forum, name: 'freetown') }
  let(:updater) { create_member(freetown) }
  let!(:project) { create(:project, forum: freetown) }
  let!(:question) { create(:question, forum: freetown, project: project) }

  test 'string for activities of question' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    assert_equal "[#{question.publisher.display_name}](/u/#{question.publisher.url}) "\
                  "posted a challenge in [#{project.display_name}](/p/#{project.id})",
                 Argu::ActivityString.new(create_activity, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "updated [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(update_activity, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "trashed [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(trash_activity, true).to_s
  end

  test 'string for create of deleted question' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    destroy_resource(question, updater)
    destroy_activity = Activity.last
    assert_equal "[#{question.publisher.display_name}](/u/#{question.publisher.url}) "\
                  "posted a challenge in [#{project.display_name}](/p/#{project.id})",
                 Argu::ActivityString.new(create_activity, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "updated #{question.display_name}",
                 Argu::ActivityString.new(update_activity, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "trashed #{question.display_name}",
                 Argu::ActivityString.new(trash_activity, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "deleted #{question.display_name}",
                 Argu::ActivityString.new(destroy_activity, true).to_s
  end

  test 'string for create of question with deleted parent' do
    destroy_resource(project)
    question.reload
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, updater).activities.last
    trash_activity = trash_resource(question, updater).activities.last
    assert_equal "[#{question.publisher.display_name}](/u/#{question.publisher.url}) "\
                  "posted a challenge in #{project.display_name}",
                 Argu::ActivityString.new(create_activity, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "updated [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(update_activity, true).to_s
    assert_equal "[#{updater.display_name}](/u/#{updater.url}) "\
                  "trashed [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(trash_activity, true).to_s
  end

  test 'string for create of question by deleted user' do
    create_activity = question.activities.first
    update_activity = update_resource(question, {content: 'updated content'}, question.publisher).activities.last
    trash_activity = trash_resource(question, question.publisher).activities.last
    question.publisher.destroy
    assert_equal "#{question.publisher.display_name} "\
                  "posted a challenge in [#{project.display_name}](/p/#{project.id})",
                 Argu::ActivityString.new(create_activity.reload, true).to_s
    assert_equal "#{question.publisher.display_name} "\
                  "updated [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(update_activity.reload, true).to_s
    assert_equal "#{question.publisher.display_name} "\
                  "trashed [#{question.display_name}](/q/#{question.id})",
                 Argu::ActivityString.new(trash_activity.reload, true).to_s
  end
end
