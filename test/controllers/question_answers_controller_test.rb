require 'test_helper'

class QuestionAnswersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:owner) { FactoryGirl.create(:user) }
  let!(:page) { FactoryGirl.create(:page, owner: owner.profile) }
  let!(:holland) { FactoryGirl.create(:forum, page: page, name: 'holland') }
  let(:question) { FactoryGirl.create(:question, forum: holland) }
  let(:motion) { FactoryGirl.create(:motion, forum: holland) }
  let!(:question_answer) { FactoryGirl.create(:question_answer, question: question) }

  ####################################
  # As Guest
  ####################################
  test 'guest should not get new' do
    get :new, question_id: question
    assert_redirected_to root_path
  end

  test 'guest should not post create' do
    sign_in user

    assert_no_difference('QuestionAnswer.count') do
      post :create,
           question_id: question,
           question_answer: {
               motion_id: motion.id
           }
    end

    assert_redirected_to root_path
    assert assigns(:question_answer)
    assert_not assigns(:question_answer).persisted?
  end

  test 'guest should not delete destroy' do
    assert_no_difference('QuestionAnswer.count') do
      delete :destroy,
             id: question_answer.id
    end

    assert_redirected_to root_path
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'user should not get new' do
    sign_in user

    get :new, question_id: question
    assert_redirected_to root_path
  end

  test 'user should not post create' do
    sign_in user

    assert_no_difference('QuestionAnswer.count') do
      post :create,
           question_id: question,
           question_answer: {
               motion_id: motion.id
           }
    end

    assert_redirected_to root_path
    assert assigns(:question_answer)
    assert_not assigns(:question_answer).persisted?
  end

  test 'user should not delete destroy' do
    sign_in user

    assert_no_difference('QuestionAnswer.count') do
      delete :destroy,
             id: question_answer.id
    end

    assert_redirected_to root_path
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(holland) }

  test 'manager should get new' do
    sign_in manager

    get :new, question_id: question
    assert_response 200
  end

  test 'manager should post create' do
    sign_in manager

    assert_difference('QuestionAnswer.count', 1) do
      post :create,
           question_id: question,
           question_answer: {
               motion_id: motion.id
           }
    end

    assert_redirected_to question_path(question)
    assert assigns(:question_answer)
    assert_equal manager.profile, assigns(:question_answer).creator
  end

  test 'manager should delete destroy' do
    sign_in manager

    assert_difference('QuestionAnswer.count', -1) do
      delete :destroy,
           id: question_answer.id
    end

    assert_redirected_to question_path(question)
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should get new' do
    sign_in owner

    get :new, question_id: question
    assert_response 200
  end

  test 'owner should post create' do
    sign_in owner

    assert_difference('QuestionAnswer.count', 1) do
      post :create,
           question_id: question,
           question_answer: {
               motion_id: motion.id
           }
    end

    assert_redirected_to question_path(question)
    assert assigns(:question_answer)
    assert_equal owner.profile, assigns(:question_answer).creator
  end

  test 'owner should delete destroy' do
    sign_in owner

    assert_difference('QuestionAnswer.count', -1) do
      delete :destroy,
             id: question_answer.id
    end

    assert_redirected_to question_path(question)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { FactoryGirl.create(:user, :staff) }

  test 'staff should get new' do
    sign_in staff

    get :new, question_id: question
    assert_response 200
  end

  test 'staff should post create' do
    sign_in staff

    assert_difference('QuestionAnswer.count', 1) do
      post :create,
           question_id: question,
           question_answer: {
               motion_id: motion.id
           }
    end

    assert_redirected_to question_path(question)
    assert assigns(:question_answer)
    assert_equal staff.profile, assigns(:question_answer).creator
  end

  test 'staff should delete destroy' do
    sign_in staff

    assert_difference('QuestionAnswer.count', -1) do
      delete :destroy,
             id: question_answer.id
    end

    assert_redirected_to question_path(question)
  end

end
