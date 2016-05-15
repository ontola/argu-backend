require 'test_helper'

class QuestionAnswersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_common_objects :user, :manager, :staff, :owner!, :page!, :motion, :question,
                        freetown: {page: -> { page }}

  ####################################
  # As Guest
  ####################################
  test 'guest should not get new' do
    get :new,
        question_answer: {
          question_id: question
        }
    assert_redirected_to root_path
  end

  test 'guest should not post create' do
    sign_in user

    post :create,
         question_answer: {
           question_id: question,
           motion_id: motion.id
         }

    assert_redirected_to root_path
    assert assigns(:question_answer)
    assert_equal nil, assigns(:motion).question_id
  end

  ####################################
  # As User
  ####################################
  test 'user should not get new' do
    sign_in user

    get :new,
        question_answer: {
          question_id: question
        }
    assert_redirected_to root_path
  end

  test 'user should not post create' do
    sign_in user

    post :create,
         question_answer: {
           question_id: question,
           motion_id: motion.id
         }

    assert_redirected_to root_path
    assert assigns(:question_answer)
    assert_equal nil, assigns(:motion).question_id
  end

  ####################################
  # As Manager
  ####################################
  test 'manager should get new' do
    sign_in manager

    get :new,
        question_answer: {
          question_id: question
        }
    assert_response 200
  end

  test 'manager should post create' do
    sign_in manager

    post :create,
         question_answer: {
           question_id: question,
           motion_id: motion.id
         }

    assert_redirected_to question_path(question)
    assert_equal question.id, assigns(:motion).question_id
    assert assigns(:question_answer)
  end

  ####################################
  # As Owner
  ####################################
  test 'owner should get new' do
    sign_in owner

    get :new,
        question_answer: {
          question_id: question
        }
    assert_response 200
  end

  test 'owner should post create' do
    sign_in owner

    post :create,
         question_answer: {
           question_id: question,
           motion_id: motion.id
         }

    assert_redirected_to question_path(question)
    assert_equal question.id, assigns(:motion).question_id
    assert assigns(:question_answer)
  end

  ####################################
  # As Staff
  ####################################
  test 'staff should get new' do
    sign_in staff

    get :new,
        question_answer: {
          question_id: question
        }
    assert_response 200
  end

  test 'staff should post create' do
    sign_in staff

    post :create,
         question_answer: {
           question_id: question,
           motion_id: motion.id
         }

    assert_redirected_to question_path(question)
    assert_equal question.id, assigns(:motion).question_id
    assert assigns(:question_answer)
  end
end
