# frozen_string_literal: true

require 'test_helper'

class SubmissionsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user }
  let!(:survey) { create(:survey, parent: freetown) }
  let(:guest_submission) { create(:submission, parent: survey, publisher: guest_user) }
  let(:user_submission) { create(:submission, parent: survey, publisher: user) }
  let(:submission_body) do
    {
      NS.argu[:string] => 'Str',
      NS.argu[:integer] => 1,
      NS.argu[:array] => [
        'a',
        1
      ]
    }
  end
  let(:submission_body_emp_json) do
    {'.': submission_body}.to_emp_json.to_json
  end

  ####################################
  # as Guest
  ####################################
  test 'guest should post submission' do
    sign_in guest_user

    assert_difference('Edge.count') do
      post survey.collection_iri(:submissions)
    end

    assert_response :created
    assert Submission.last.user.guest?
    assert_equal Submission.last.session_id, guest_user.session_id
  end

  test 'guest should update submission' do
    sign_in guest_user

    guest_submission
    assert_no_difference('Edge.count') do
      assert_no_difference('Property.count') do
        put guest_submission.complete_iri
      end
    end

    assert_response :success
    assert guest_submission.reload.status, :submission_completed
  end

  test 'guest should update submission with body' do
    sign_in guest_user

    guest_submission
    assert_no_difference('Submission.count') do
      assert_difference('Thing.count') do
        assert_difference('Property.count' => 6) do
          put guest_submission.complete_iri,
              params: submission_body_emp_json,
              headers: argu_headers(content_type: :empjson)
        end
      end
    end

    assert_response :success
    assert guest_submission.reload.status, :submission_completed
    assert_submission_data(guest_submission)
  end

  test 'other guest should not update submission' do
    sign_in other_guest_user

    guest_submission
    assert_no_difference('Edge.count') do
      put guest_submission.complete_iri
    end

    assert_response :forbidden
  end

  test 'guest should not update user submission' do
    sign_in guest_user

    user_submission
    assert_no_difference('Edge.count') do
      put user_submission.complete_iri
    end

    assert_response :forbidden
  end

  ####################################
  # as User
  ####################################
  test 'user should post submission' do
    sign_in user

    assert_difference('Edge.count') do
      post survey.collection_iri(:submissions)
    end

    assert_response :created
    assert_equal Submission.last.publisher, user
  end

  test 'user should update submission' do
    sign_in user

    user_submission
    assert_no_difference('Edge.count') do
      assert_no_difference('Property.count') do
        put user_submission.complete_iri
      end
    end

    assert_response :success
    assert user_submission.reload.status, :submission_completed
  end

  test 'user should update submission with body' do
    sign_in user

    user_submission
    assert_no_difference('Submission.count') do
      assert_difference('Thing.count') do
        assert_difference('Property.count' => 6) do
          put user_submission.complete_iri,
              params: submission_body_emp_json,
              headers: argu_headers(content_type: :empjson)
        end
      end
    end

    assert_response :success
    assert user_submission.reload.status, :submission_completed
    assert_submission_data(user_submission)
  end

  test 'other user should not update submission' do
    sign_in other_guest_user

    user_submission
    assert_no_difference('Edge.count') do
      put user_submission.complete_iri
    end

    assert_response :forbidden
  end

  private

  def assert_submission_data(submission) # rubocop:disable Metrics/AbcSize
    assert_equal 5, submission.submission_data.properties.count

    statements = submission.submission_data.property_statements
    submission_body.each do |key, values|
      (values.is_a?(Array) ? values : [values]).each do |value|
        assert(statements.find { |s| s.predicate == key && s.object.object == value }, "#{key} == #{value} not found")
      end
    end
  end
end
