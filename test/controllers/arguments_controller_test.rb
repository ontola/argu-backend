require 'test_helper'

class ArgumentsControllerTest < Argu::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
  let(:motion) { FactoryGirl.create(:motion, tenant: :holland) }
  let(:argument) { FactoryGirl.create(:argument, :with_comments, tenant: :holland, motion: motion) }

  ####################################
  # Not logged in
  ####################################
  test 'should get show when not logged in', tenant: :holland do
    get :show,
        id: argument

    assert_response 200
    assert assigns(:argument)
    assert assigns(:comments)

    assert argument.comment_threads.any?(&:is_trashed), 'No thrashed comments in test'
    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' }, 'Trashed comments are visible'
  end

  ####################################
  # As user
  ####################################
  test 'should get show', tenant: :holland do
    sign_in users(:user)

    get :show,
        id: argument

    assert_response 200
    assert assigns(:argument)
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' }, 'Trashed comments are visible'
  end

  test 'should get new pro', tenant: :holland do
    sign_in users(:user)

    _motion = motion

    get :new,
        motion_id: _motion,
        pro: 'pro'

    assert_response 200
    assert assigns(:argument)
    assert assigns(:argument).motion == _motion
    assert assigns(:argument).pro === true, "isn't assigned pro attribute"
  end

  test 'should get new con', tenant: :holland do
    sign_in users(:user)

    get :new,
        motion_id: motion,
        pro: 'con'

    assert_response 200
    assert assigns(:argument)
    assert assigns(:argument).motion == motion
    assert assigns(:argument).pro === false, "isn't assigned pro attribute"
  end

  ####################################
  # As member
  ####################################
  let(:member) { make_member(holland) }

  test 'should post create pro' do
    sign_in member

    assert_difference('Argument.count') do
      assert_difference('Vote.count') do
        post :create,
             argument: {
                 motion_id: motion,
                 pro: 'pro',
                 title: 'Test argument pro',
                 content: 'Test argument pro-tents',
                 auto_vote: 'true'
             }
      end
    end

    assert assigns(:argument)
    assert assigns(:argument).motion == motion
    assert assigns(:argument).title == 'Test argument pro', "title isn't assigned"
    assert assigns(:argument).content == 'Test argument pro-tents', "content isn't assigned"
    assert assigns(:argument).pro === true, "isn't assigned pro attribute"
    assert_redirected_to assigns(:argument).motion
  end

  test 'should post create con' do
    sign_in member

    assert_difference('Argument.count') do
      assert_difference('Vote.count') do
        post :create,
             argument: {
                 motion_id: motion,
                 pro: 'con',
                 title: 'Test argument con',
                 content: 'Test argument con-tents',
                 auto_vote: 'true'
             }
      end
    end

    assert assigns(:argument)
    assert assigns(:argument).motion == motion
    assert assigns(:argument).title == 'Test argument con', "title isn't assigned"
    assert assigns(:argument).content == 'Test argument con-tents', "content isn't assigned"
    assert assigns(:argument).pro === false, "isn't assigned pro attribute"
    assert_redirected_to assigns(:argument).motion
  end

  test 'should post create pro without auto_vote' do
    sign_in member

    assert_difference('Argument.count') do
      assert_no_difference('Vote.count') do
        post :create,
             argument: {
                 motion_id: motion,
                 pro: 'pro',
                 title: 'Test argument pro',
                 content: 'Test argument pro-tents',
                 auto_vote: 'false'
             }
      end
    end
  end

  ####################################
  # As creator
  ####################################
  let(:creator) { make_creator(argument, make_member(holland)) }

  test 'should get edit' do
    sign_in creator

    get :edit, id: argument

    assert_response 200
    assert assigns(:argument)
  end

  test 'should put update on own argument' do
    sign_in creator

    put :update,
        id: argument,
        argument: {
            title: 'New title',
            content: 'new contents'
        }

    assert_not_nil assigns(:argument)
    assert_equal 'New title', assigns(:argument).title
    assert_equal 'new contents', assigns(:argument).content
    assert_redirected_to assigns(:argument)
  end

  test "'should not put update on others' argument'" do
    sign_in make_member(holland)

    put :update,
        id: argument,
        argument: {
            title: 'New title',
            content: 'new contents'
        }

    assert_equal argument, assigns(:argument)
  end

end
