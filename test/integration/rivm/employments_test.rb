# frozen_string_literal: true

require 'test_helper'

class EmploymentsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:employment) { create(:employment, parent: argu) }
  let(:employment_moderation) { EmploymentModeration.find(employment.id) }
  let(:validated_employment) { create(:employment, parent: argu, validated: true) }
  let(:intervention_type) { create(:intervention_type, parent: argu) }
  let(:intervention) { create(:intervention, employment_id: employment_moderation.id, parent: intervention_type) }

  test 'user should get employment' do
    sign_in user
    get employment
    assert_response :success
    refute_triple(nil, NS::SCHEMA[:email], employment.user.email)
  end

  test 'user should not get employment moderation' do
    sign_in user
    get employment_moderation
    assert_response :forbidden
    refute_triple(nil, NS::SCHEMA[:email], employment.user.email)
  end

  ####################################
  # As Administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should get employment' do
    sign_in administrator
    get employment
    assert_response :success
    refute_triple(nil, NS::SCHEMA[:email], employment.user.email)
  end

  test 'administrator should not get employment moderation' do
    sign_in administrator
    get employment_moderation
    assert_response :success
    expect_triple(nil, NS::SCHEMA[:email], employment.user.email)
  end

  test 'administrator should confirm employment moderation' do
    sign_in administrator
    intervention
    assert_not intervention.is_published?
    Sidekiq::Testing.inline! do
      put employment_moderation, params: {employment_moderation: {validated: true}}
    end
    assert_response :success
    assert intervention.reload.is_published?
  end

  test 'administrator should delete destroy employment moderation' do
    sign_in administrator
    intervention
    assert_difference(
      'Employment.count' => -1,
      'Intervention.count' => -1,
      "Property.where(predicate: '#{NS::RIVM[:employmentId]}').count" => -1
    ) do
      delete employment_moderation
      assert_response :success
    end
  end
end
