# frozen_string_literal: true

require 'test_helper'

class JSONApiResponsesTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:user) { create(:user) }

  test 'guest should get 401' do
    post motion_arguments_url(motion),
         params: {
           format: :json_api,
           data: {
             type: 'arguments',
             attributes: {
               pro: true,
               title: 'Argument title'
             }
           }
         }

    assert_response 401
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Unauthorized',
                   message: 'You must authenticate before you can continue.',
                   code: 'NOT_A_USER'
                 )
  end

  test 'user should get 404 when not allowed' do
    sign_in user
    post forum_motions_url(cairo),
         params: {
           format: :json_api,
           data: {
             type: 'motions',
             attributes: {
               title: 'Motion title',
               content: 'Motion body'
             }
           }
         }

    assert_response 403
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Forbidden',
                   message: "You're not authorized for that action. (create)",
                   code: 'NOT_AUTHORIZED'
                 )
  end

  test 'user should get 400 with empty body' do
    sign_in user
    post motion_arguments_url(motion),
         params: {
           format: :json_api
         }

    assert_response 400
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Bad Request',
                   message: 'param is missing or the value is empty: argument',
                   code: 'BAD_REQUEST'
                 )
  end

  test 'user should get 400 with empty data' do
    sign_in user
    post motion_arguments_url(motion),
         params: {
           format: :json_api,
           data: {}
         }

    assert_response 400
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Bad Request',
                   message: 'param is missing or the value is empty: argument',
                   code: 'BAD_REQUEST'
                 )
  end

  test 'user should get 400 with missing type' do
    sign_in user
    post motion_arguments_url(motion),
         params: {
           format: :json_api,
           data: {
             attributes: {
               pro: true,
               title: 'Argument title'
             }
           }
         }

    assert_response 400
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Bad Request',
                   message: 'param is missing or the value is empty: type',
                   code: 'BAD_REQUEST'
                 )
  end

  test 'user should get 400 with wrong type' do
    sign_in user
    post motion_arguments_url(motion),
         params: {
           format: :json_api,
           data: {
             type: 'motions',
             attributes: {
               pro: true,
               title: 'Argument title'
             }
           }
         }

    assert_response 400
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Bad Request',
                   message: 'found unpermitted parameter: :type',
                   code: 'BAD_REQUEST'
                 )
  end

  test 'user should get 400 with missing attributes' do
    sign_in user
    post motion_arguments_url(motion),
         params: {
           format: :json_api,
           data: {
             type: 'arguments'
           }
         }

    assert_response 400
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Bad Request',
                   message: 'param is missing or the value is empty: attributes',
                   code: 'BAD_REQUEST'
                 )
  end

  test 'user should get 422 with multiple wrong fields' do
    sign_in user
    post forum_motions_path(freetown),
         params: {
           format: :json_api,
           data: {
             type: 'motions',
             attributes: {
               bla: 'bla'
             }
           }
         }

    assert_response 422
    assert_equal parsed_body,
                 'errors' => [
                   json_api_errors(
                     status: 'Unprocessable Entity',
                     source: {'parameter' => 'content'},
                     message: "Content can't be blank",
                     code: 'VALUE_BLANK'
                   ),
                   json_api_errors(
                     status: 'Unprocessable Entity',
                     source: {'parameter' => 'content'},
                     message: 'Content is too short (minimum is 5 characters)',
                     code: 'VALUE_TOO_SHORT'
                   ),
                   json_api_errors(
                     status: 'Unprocessable Entity',
                     source: {'parameter' => 'title'},
                     message: "Title can't be blank",
                     code: 'VALUE_BLANK'
                   ),
                   json_api_errors(
                     status: 'Unprocessable Entity',
                     source: {'parameter' => 'title'},
                     message: 'Title is too short (minimum is 5 characters)',
                     code: 'VALUE_TOO_SHORT'
                   )
                 ].flatten
  end

  private

  def json_api_errors(code: nil, message: nil, source: nil, status: nil)
    errors = {}
    errors['status'] = status if status.present?
    errors['message'] = message if message.present?
    errors['code'] = code if code.present?
    errors['source'] = source if source.present?
    [errors]
  end
end
