# frozen_string_literal: true
require 'test_helper'

class QuestionAnswersControllerTest < ActionController::TestCase
  define_freetown
  let(:super_admin) { create_super_admin(freetown) }
  let(:question) { create(:question, parent: freetown.edge) }
  let(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Guest
  ####################################
  test 'guest should not get new' do
    get :new,
        params: {
          question_answer: {
            question_id: question
          }
        }
    assert_not_a_user
  end

  test 'guest should not post create' do
    sign_in user

    post :create,
         params: {
           question_answer: {
             question_id: question,
             motion_id: motion.id
           }
         }
    assert_equal nil, assigns(:resource).motion.question_id
    assert_response 403
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get new' do
    sign_in user

    get :new,
        params: {
          question_answer: {
            question_id: question
          }
        }
    assert_response 403
  end

  test 'user should not post create' do
    sign_in user

    post :create,
         params: {
           question_answer: {
             question_id: question,
             motion_id: motion.id
           }
         }
    assert_equal nil, assigns(:resource).motion.question_id

    assert_response 403
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  test 'manager should get new' do
    sign_in manager

    get :new,
        params: {
          question_answer: {
            question_id: question
          }
        }
    assert_response 200
  end

  test 'manager should post create' do
    sign_in manager

    post :create,
         params: {
           question_answer: {
             question_id: question,
             motion_id: motion.id
           }
         }

    assert_redirected_to question_path(question)
    assert_equal question.id, assigns(:resource).motion.question_id
  end

  ####################################
  # As Admin
  ####################################

  test 'super_admin should get new' do
    sign_in super_admin

    get :new,
        params: {
          question_answer: {
            question_id: question
          }
        }
    assert_response 200
  end

  test 'super_admin should post create' do
    sign_in super_admin

    post :create,
         params: {
           question_answer: {
             question_id: question,
             motion_id: motion.id
           }
         }

    assert_redirected_to question_path(question)
    assert_equal question.id, assigns(:resource).motion.question_id
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get new' do
    sign_in staff

    get :new,
        params: {
          question_answer: {
            question_id: question
          }
        }
    assert_response 200
  end

  test 'staff should post create' do
    sign_in staff

    post :create,
         params: {
           question_answer: {
             question_id: question,
             motion_id: motion.id
           }
         }

    assert_redirected_to question_path(question)
    assert_equal question.id, assigns(:resource).motion.question_id
  end
end
