require 'test_helper'

class MotionsControllerTest < Argu::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum,
                                      name: 'holland') }
  let(:motion) { FactoryGirl.create(:motion,
                                    :with_arguments) }

  ####################################
  # As Guest
  ####################################
  test 'should get show when not logged in', tenant: :holland do
    get :show, id: motion

    assert_response 200
    assert_not_nil assigns(:motion)
    assert_not_nil assigns(:vote)

    assert motion.arguments.where(is_trashed: true).count > 0, 'No trashed arguments to test visibility on'
    assert_not ([:pro, :con].any? { |stance| assigns(:arguments)[stance][:collection].any?(&:is_trashed?) }), 'Trashed arguments are visible'
  end

  test 'should not get edit when not logged in' do
    get :edit, id: motion

    assert_redirected_to root_path
    assert assigns(:motion)
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should get show', tenant: :holland do
    sign_in user

    get :show, id: motion

    assert_response 200
    assert_not_nil assigns(:motion)
    assert_not_nil assigns(:vote)

    assert_not assigns(:arguments).any? { |arr| arr[1][:collection].any?(&:is_trashed?) }, 'Trashed arguments are visible'
  end

  test 'should get new', tenant: :holland do
    sign_in user

    get :new

    assert_response 200
    assert_not_nil assigns(:motion)
  end

  test 'should not get edit', tenant: :holland do
    sign_in user

    get :edit, id: motion

    assert_redirected_to root_path
    assert assigns(:motion)
  end

  test 'should not post create', tenant: :holland do
    sign_in user

    assert_no_difference 'Motion.count' do
      post :create, motion: {
                      title: 'Motion',
                      content: 'Contents'}
    end
    assert_nil assigns(:motion)
    assert_redirected_to root_path
  end

  ####################################
  # As Member
  ####################################
  let(:member) { make_member(holland) }

  test 'should get edit', tenant: :holland do
    sign_in member

    get :edit, id: motion

    assert_response 200
    assert assigns(:motion)
  end

  test 'should post create', tenant: :holland do
    sign_in member

    assert_difference 'Motion.count' do
      post :create, motion: {
                      title: 'Motion',
                      content: 'Contents'}
    end
    assert_not_nil assigns(:motion)
    assert_redirected_to motion_path(assigns(:motion),
                                     start_motion_tour: true)
  end

  test 'should not start tour on second motion', tenant: :holland do
    sign_in make_member(holland,
                        FactoryGirl.create(:user_with_memberships,
                                           :with_motions))

    post :create, motion: {title: 'Motion', content: 'Contents'}
    assert_not_nil assigns(:motion)
    assert_redirected_to motion_path(assigns(:motion))
  end

  let!(:custom_rules) { FactoryGirl.create(:forum,
                                           name: 'custom_rules') }

  test 'should not post create without create_without_question', tenant: :custom_rules do
    FactoryGirl.create(:rule,
                       tenant: :custom_rules,
                       model_type: 'Motion',
                       action: :create_without_question?,
                       role: :member,
                       trickles: Rule.trickles[:trickles_down])

    sign_in make_member(custom_rules)

    assert_no_difference 'Motion.count' do
      post :create,
           motion: {
               title: 'Motion',
               content: 'Contents'
           }
    end
    assert_not_nil assigns(:motion)
    assert_not assigns(:motion).persisted?
    assert_redirected_to root_path
  end

  test 'should post create without create_without_question with question', tenant: :custom_rules do
    FactoryGirl.create(:rule,
                       tenant: :custom_rules,
                       model_type: 'Motion',
                       action: :create_without_question?,
                       role: :member,
                       trickles: Rule.trickles[:trickles_down])

    sign_in make_member(custom_rules)

    assert_difference 'Motion.count', 1 do
      post :create,
           motion: {
               title: 'Motion',
               content: 'Contents',
               question_id: FactoryGirl.create(:question)
           }
    end
    assert_not_nil assigns(:motion)
    assert assigns(:motion).persisted?
    assert_redirected_to motion_path(assigns(:motion),
                                     start_motion_tour: true)
  end

  test 'should not put update on others motion' do
    sign_in users(:user2)

    put :update, motion: {
                   title: 'New title',
                   content: 'new contents'}

    assert_equal motion, assigns(:motion)
  end

  ####################################
  # As Creator
  ####################################
  let(:creator) { make_member(holland,
                              FactoryGirl.create(:user)) }
  let(:creator_motion) { FactoryGirl.create(:motion,
                                            tenant: :holland,
                                            creator: creator.profile) }

  test 'should put update on own motion', tenant: :holland do
    sign_in creator

    put :update, id: creator_motion.id,
                 motion: {
                     title: 'New title',
                     content: 'new contents'}

    assert_not_nil assigns(:motion)
    assert_redirected_to motion_url(assigns(:motion))
    assert_equal 'New title', assigns(:motion).title
    assert_equal 'new contents', assigns(:motion).content
  end

  test 'should not get convert', tenant: :holland do
    sign_in creator

    get :convert, motion_id: creator_motion
    assert_redirected_to root_url
  end

  test 'should not put convert', tenant: :holland do
    sign_in creator

    put :convert, motion_id: creator_motion
    assert_redirected_to root_url
  end

  test 'should not get move', tenant: :holland do
    sign_in creator

    get :move, motion_id: creator_motion
    assert_redirected_to root_url
  end

  test 'should not put move', tenant: :holland do
    sign_in creator

    put :move, motion_id: creator_motion
    assert_redirected_to root_url
  end

  ####################################
  # As Manager
  ####################################

  ####################################
  # As Staff
  ####################################
  let(:staff) { FactoryGirl.create(:user, :staff) }

  test 'should get convert', tenant: :holland do
    sign_in staff

    get :convert, motion_id: motion
    assert_response 200
  end

  test 'should put convert', tenant: :holland do
    sign_in staff

    put :convert!, motion_id: motion,
                   motion: {
                       f_convert: 'questions'}

    assert assigns(:result)
    assert_redirected_to assigns(:result)[:new]

    assert_equal Question, assigns(:result)[:new].class
    assert assigns(:result)[:old].destroyed?

    # Test direct relations
    assert_equal 0, assigns(:result)[:old].arguments.count

    assert_equal 0, assigns(:result)[:old].taggings.count
    assert_equal 2, assigns(:result)[:new].taggings.count

    assert_equal 0, assigns(:result)[:old].votes.count
    assert_equal 2, assigns(:result)[:new].votes.count

    assert_equal 0, assigns(:result)[:old].activities.count
    assert_equal 1, assigns(:result)[:new].activities.count

  end

  test 'should get move', tenant: :holland do
    sign_in staff

    get :move, motion_id: motion
    assert_response 200
  end

  test 'should put move!', tenant: :holland do
    sign_in staff

    assert_differences [['forums(:utrecht).reload.motions_count', -1],
                        ['forums(:amsterdam).reload.motions_count', 1]] do
      put :move!, motion_id: motion,
                  motion: {
                      forum_id: forums(:amsterdam).id }
    end
    assert_redirected_to assigns(:motion)

    assert assigns(:motion)
    assert_equal forums(:amsterdam), assigns(:motion).forum
    forum_id = forums(:amsterdam).id
    assigns(:motion).arguments.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assert assigns(:motion).questions.blank?
    assigns(:motion).activities.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assigns(:motion).taggings.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
  end
end
