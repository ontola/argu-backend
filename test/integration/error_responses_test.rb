# frozen_string_literal: true

require 'test_helper'

class ErrorResponsesTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo
  let(:motion) { create(:motion, parent: freetown) }
  let(:user) { create(:user) }

  test 'guest should get 401' do
    sign_in create_guest_user
    post motion.collection_iri(:pro_arguments),
         params: {
           pro_argument: {
             pro: true,
             title: 'Argument title'
           }
         },
         headers: argu_headers(accept: :json_api)

    assert_response 401
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Unauthorized',
                   message: 'Please sign in to continue',
                   code: 'NOT_A_USER'
                 )
  end

  test 'user should get 404 when not allowed' do
    sign_in user
    tenant_from(cairo)
    post cairo.collection_iri(:motions),
         params: {
           motion: {
             title: 'Motion title',
             content: 'Motion body'
           }
         },
         headers: argu_headers(accept: :json_api)

    assert_response 403
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Forbidden',
                   message: "You're not authorized for this action. (create)",
                   code: 'NOT_AUTHORIZED'
                 )
  end

  test 'user should get 422 with empty body' do
    sign_in user
    post motion.collection_iri(:pro_arguments),
         params: {},
         headers: argu_headers(accept: :json_api)

    assert_response 422
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Unprocessable Entity',
                   message: 'param is missing or the value is empty: pro_argument',
                   code: 'PARAMETER_MISSING'
                 )
  end

  test 'user should get 422 with empty data' do
    sign_in user
    post motion.collection_iri(:pro_arguments),
         params: {
           pro_argument: {}
         },
         headers: argu_headers(accept: :json_api)

    assert_response 422
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Unprocessable Entity',
                   message: 'param is missing or the value is empty: pro_argument',
                   code: 'PARAMETER_MISSING'
                 )
  end

  test 'user should get 400 with wrong type' do
    sign_in user
    post motion.collection_iri(:pro_arguments),
         params: {
           motion: {
             pro: true,
             title: 'Argument title'
           }
         },
         headers: argu_headers(accept: :json_api)

    assert_response 422
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Unprocessable Entity',
                   message: 'param is missing or the value is empty: pro_argument',
                   code: 'PARAMETER_MISSING'
                 )
  end

  test 'user should get 400 with missing attributes' do
    sign_in user
    post motion.collection_iri(:pro_arguments),
         params: {
           pro_argument: {}
         },
         headers: argu_headers(accept: :json_api)

    assert_response 422
    assert_equal parsed_body,
                 'errors' => json_api_errors(
                   status: 'Unprocessable Entity',
                   message: 'param is missing or the value is empty: pro_argument',
                   code: 'PARAMETER_MISSING'
                 )
  end

  test 'user should get 422 with multiple wrong fields' do
    sign_in user
    post freetown.collection_iri(:questions),
         params: {
           question: {
             bla: 'bla'
           }
         },
         headers: argu_headers(accept: :json_api)

    assert_response 422
    assert_equal parsed_body,
                 'errors' => [
                   json_api_errors(
                     status: 'Unprocessable Entity',
                     source: {'parameter' => 'description'},
                     message: "Description can't be blank",
                     code: 'VALUE_BLANK'
                   ),
                   json_api_errors(
                     status: 'Unprocessable Entity',
                     source: {'parameter' => 'description'},
                     message: 'Description is too short (minimum is 5 characters)',
                     code: 'VALUE_TOO_SHORT'
                   ),
                   json_api_errors(
                     status: 'Unprocessable Entity',
                     source: {'parameter' => 'display_name'},
                     message: "Display name can't be blank",
                     code: 'VALUE_BLANK'
                   ),
                   json_api_errors(
                     status: 'Unprocessable Entity',
                     source: {'parameter' => 'display_name'},
                     message: 'Display name is too short (minimum is 4 characters)',
                     code: 'VALUE_TOO_SHORT'
                   )
                 ].flatten
  end

  test 'user should get 404' do
    sign_in user
    test_error(
      :get,
      '/argu/non_existing',
      {},
      404,
      status: 'Not Found',
      message: 'ActiveRecord::RecordNotFound',
      code: 'NOT_FOUND',
      error: 'RecordNotFound'
    )
  end

  private

  def test_error(method, url, params, status, opts)
    test_error_json_api(method, url, params, status, opts)
    test_error_n3(method, url, params, status, opts)
  end

  def test_error_json_api(method, url, params, status, opts)
    send(method, url, params: params, headers: argu_headers(accept: :json_api))

    errors = json_api_errors(**opts.except(:error))

    assert_response status
    assert_equal parsed_body, 'errors' => errors
  end

  def test_error_n3(method, path, params, status, opts) # rubocop:disable Metrics/AbcSize
    send(method, path, params: params, headers: argu_headers(accept: :n3))

    assert_response status

    ActsAsTenant.current_tenant = argu
    subject = RDF::URI("#{Rails.application.config.origin}#{path}")

    expect_resource_type(NS.ontola["errors/#{opts[:error]}Error"], iri: subject)
    expect_triple(subject, NS.schema.name, I18n.t('status')[status])
    expect_triple(subject, NS.schema.text, opts[:message])
  end

  def json_api_errors(code: nil, message: nil, source: nil, status: nil)
    errors = {}
    errors['status'] = status if status.present?
    errors['message'] = message if message.present?
    errors['code'] = code if code.present?
    errors['source'] = source if source.present?
    [errors]
  end
end
