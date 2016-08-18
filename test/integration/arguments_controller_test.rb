require 'test_helper'

class ArgumentsControllerTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let!(:motion) do
    create(:motion,
           :with_follower,
           parent: freetown.edge,
           creator: create(:user,
                           :follows_reactions_directly,
                           :viewed_notifications_hour_ago)
                      .profile)
  end
  let(:subject) do
    create(:argument,
           parent: motion.edge,
           publisher: creator)
  end
  let!(:comment) do
    create(:comment,
           parent: subject.edge)
  end
  let!(:trashed_comment) do
    create(:comment,
           parent: subject.edge,
           is_trashed: true)
  end

  let(:project) { create(:project, parent: freetown.edge) }
  let(:project_motion) { create(:motion, parent: project.edge) }
  let(:project_argument) do
    create(:argument,
           parent: project_motion.edge)
  end

  let(:pub_project) do
    create(:project,
           argu_publication: build(:publication),
           parent: freetown.edge)
  end
  let(:pub_project_motion) { create(:motion, parent: pub_project.edge) }
  let(:pub_project_argument) do
    create(:argument,
           parent: pub_project_motion.edge)
  end

  def default_create_attributes(parent: nil)
    super.merge(motion_id: parent.id)
  end

  def create_path(parent)
    url_for([parent.forum, model_class])
  end

  def new_path(parent)
    url_for([:new, parent.forum, :argument, motion_id: parent.id, pro: 'pro'])
  end

  define_tests do
    hash = {}
    define_test(hash, :new, options: {parent: :motion})
    define_test(hash, :create, options: {
      parent: :motion,
      analytics: stats_opt('arguments', 'create_success'),
      differences: [['Argument', 1],
                    ['Activity.loggings', 1],
                    ['Vote', 0]]})
    define_test(
      hash, :create,
      case_suffix: ' with auto_vote',
      options: {
        analytics: stats_opt('arguments', 'create_success'),
        parent: :motion,
        differences: [['Argument', 1], ['Activity.loggings', 2], ['Vote', 1]],
        attributes: {auto_vote: true}
      }
    )
    define_test(hash, :show, asserts: [
      'assigns(:comments).none? { |c| c.is_trashed? && c.body != "[DELETED]" }'
    ])
    define_test(hash, :show, case_suffix: ' nested', options: {record: :pub_project_argument})
    define_test(
      hash, :show,
      case_suffix: ' unpublished nested',
      options: {record: :project_argument},
      user_types: user_types[:show].merge(
        guest: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
        user: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
        member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']}
      ))
    define_test(hash, :show, case_suffix: ' non-existent', options: {record: 'none'}, user_types: {
      user: {should: false, response: 404}
    })
    define_test(hash, :edit)
    define_test(hash, :update)
    define_test(hash, :destroy, options: {
      analytics: stats_opt('arguments', 'destroy_success')
    })
    define_test(hash, :trash, options: {
      analytics: stats_opt('arguments', 'trash_success')
    })
  end
end
