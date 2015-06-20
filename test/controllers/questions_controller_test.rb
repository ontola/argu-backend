require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  ####################################
  # Not logged in
  ####################################
  test 'should get show when not logged in' do
    get :show, id: questions(:one).id
    assert_response 200
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:motions)

    assert_not assigns(:motions).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  ####################################
  # As user
  ####################################
  test 'should get show' do
    sign_in users(:user)

    get :show, id: questions(:one).id
    assert_response 200
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:motions)

    assert_not assigns(:motions).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  test 'should post create' do
    sign_in users(:user)

    assert_difference('Question.count') do
      post :create, forum_id: :utrecht, question: {title: 'Question', content: 'Contents'}
    end
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:forum)
    assert_redirected_to question_url(assigns(:question))
  end

  test 'should put update on own question' do
    sign_in users(:user)

    put :update, id: questions(:one), question: {title: 'New title', content: 'new contents'}

    assert_not_nil assigns(:question)
    assert_equal 'New title', assigns(:question).title
    assert_equal 'new contents', assigns(:question).content
    assert_redirected_to question_url(assigns(:question))
  end

  test 'should not put update on others question' do
    sign_in users(:user2)

    put :update, id: questions(:one), question: {title: 'New title', content: 'new contents'}

    assert_equal questions(:one), assigns(:question)
  end

  test 'should not get convert' do
    sign_in users(:user)

    get :convert, question_id: questions(:one)
    assert_redirected_to root_url
  end

  test 'should not put convert' do
    sign_in users(:user)

    put :convert, question_id: questions(:one)
    assert_redirected_to root_url
  end

  test 'should not get move' do
    sign_in users(:user)

    get :move, question_id: questions(:one)
    assert_redirected_to root_url
  end

  test 'should not put move' do
    sign_in users(:user)

    put :move, question_id: questions(:one)
    assert_redirected_to root_url
  end

  ####################################
  # For Page owners
  ####################################
  test 'should put update on page owner own question' do
    sign_in users(:user_page_manager)
    @controller.instance_variable_set :@current_profile, profiles(:profile_page)

    put :update, id: questions(:page_one), question: {title: 'New title', content: 'new contents'}

    assert_redirected_to question_url(assigns(:question))
    assert_not_nil assigns(:question)
    assert_equal 'New title', assigns(:question).title
    assert_equal 'new contents', assigns(:question).content
  end

  ####################################
  # For managers
  ####################################

  # Currently only staffers can convert items
  test 'should get convert' do
    sign_in users(:user_thom)

    get :convert, question_id: questions(:one)
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'should put convert' do
    sign_in users(:user_thom)

    put :convert!, question_id: questions(:one), question: {f_convert: 'motions'}
    assert assigns(:result)
    assert_redirected_to assigns(:result)[:new]

    assert_equal Motion, assigns(:result)[:new].class
    assert assigns(:result)[:old].destroyed?

    # Test direct relations
    assert_equal 0, assigns(:result)[:old].taggings.count
    assert_equal 1, assigns(:result)[:new].taggings.count

    assert_equal 0, assigns(:result)[:old].votes.count
    assert_equal 1, assigns(:result)[:new].votes.count

    assert_equal 0, assigns(:result)[:old].activities.count
    assert_equal 1, assigns(:result)[:new].activities.count

  end


  # Currently only staffers can move items
  test 'should get move' do
    sign_in users(:user_thom)

    get :move, question_id: questions(:one)
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'should put move!' do
    sign_in users(:user_thom)

    assert_differences [['forums(:utrecht).reload.questions_count', -1], ['forums(:amsterdam).reload.questions_count', 1]] do
      put :move!, question_id: questions(:one), question: { forum_id: forums(:amsterdam).id }
    end
    assert_redirected_to assigns(:question)

    assert assigns(:question)
    assert_equal forums(:amsterdam), assigns(:question).forum
    forum_id = forums(:amsterdam).id
    assigns(:question).motions.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assert assigns(:question).motions.blank?
    assigns(:question).activities.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assigns(:question).taggings.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end

  end

end
