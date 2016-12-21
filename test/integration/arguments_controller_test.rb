# frozen_string_literal: true
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
           edge_attributes: {trashed_at: DateTime.current})
  end

  let(:project) { create(:project, parent: freetown.edge) }
  let(:project_motion) { create(:motion, parent: project.edge) }
  let(:project_argument) do
    create(:argument,
           parent: project_motion.edge)
  end

  let(:pub_project) do
    create(:project,
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}},
           parent: freetown.edge)
  end
  let(:pub_project_motion) { create(:motion, parent: pub_project.edge) }
  let(:pub_project_argument) do
    create(:argument,
           parent: pub_project_motion.edge)
  end

  def default_create_attributes(parent: nil)
    super.merge(parent: url_for(parent))
  end

  def create_path(_parent)
    url_for(model_class)
  end

  def new_path(parent)
    url_for([:new, :argument, motion_id: parent.id, pro: 'pro'])
  end

  def self.assert_only_allowed_comments
    'assigns(:comments).none? { |c| c.is_trashed? && c.body != "[DELETED]" }'
  end

  define_tests do
    hash = {}
    define_test(hash, :new, options: {parent: :motion})
    define_test(hash, :create, options: {
                  parent: :motion,
                  analytics: stats_opt('arguments', 'create_success'),
                  differences: [['Argument', 1],
                                ['Activity.loggings', 1],
                                ['Vote', 0]]
                })
    define_test(
      hash, :create,
      suffix: ' with auto_vote',
      options: {
        analytics: stats_opt('arguments', 'create_success'),
        parent: :motion,
        differences: [['Argument', 1], ['Activity.loggings', 2], ['Vote', 1]],
        attributes: {auto_vote: true}
      }
    )
    define_test(hash, :show, asserts: [assert_only_allowed_comments]) do
      user_types[:show].except!(:non_member)
    end
    define_test(hash, :show, suffix: ' nested', options: {record: :pub_project_argument})
    define_test(hash, :show, suffix: ' unpublished nested', options: {record: :project_argument}) do
      user_types[:show].merge(
        guest: exp_res(asserts: [assert_not_authorized]),
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized])
      )
    end
    define_test(hash, :show, suffix: ' non-existent', options: {record: 'none'}) do
      {user: exp_res(response: 404)}
    end
    define_test(hash, :edit)
    define_test(hash, :update)
    define_test(hash, :destroy, options: {analytics: stats_opt('arguments', 'destroy_success')})
    define_test(hash, :trash, options: {analytics: stats_opt('arguments', 'trash_success')})
  end

  test 'user should post create pro json_api' do
    sign_in user

    assert_differences([['Argument.count', 1], ['Edge.count', 1]]) do
      post arguments_path,
           params: {
             format: :json_api,
             data: {
               type: 'arguments',
               attributes: {
                 pro: true,
                 title: 'Argument title',
                 parent: url_for(motion)
               }
             }
           }
    end

    assert_response 200
    assert assigns(:create_service).resource.pro?
  end

  test 'user should post create con json_api' do
    sign_in user

    assert_differences([['Argument.count', 1], ['Edge.count', 1]]) do
      post arguments_path,
           params: {
             format: :json_api,
             data: {
               type: 'arguments',
               attributes: {
                 pro: false,
                 title: 'Argument title',
                 parent: url_for(motion)
               }
             }
           }
    end

    assert_response 200
    assert_not assigns(:create_service).resource.pro?
  end
end
