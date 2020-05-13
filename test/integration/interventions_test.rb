# frozen_string_literal: true

require 'test_helper'

class InterventionsTest < ActionDispatch::IntegrationTest
  before do
    load(Dir[Rails.root.join('db/seeds/rivm.seeds.rb')][0])
    Apartment::Tenant.switch! :rivm
  end

  after do
    Apartment::Tenant.switch! :argu
  end

  let(:argu) do
    ActsAsTenant.current_tenant = nil
    Page.find_via_shortname('argu') ||
      create(:page, locale: 'en-GB', url: 'argu', name: 'Argu')
  end
  let(:freetown) do
    create_forum(
      :with_follower,
      parent: argu,
      public_grant: 'initiator'
    )
  end
  let(:initiator) { create_initiator(freetown) }
  let(:employment) { create(:employment, parent: argu) }
  let(:validated_employment) { create(:employment, parent: argu, validated: true) }
  let(:intervention_type) { create(:intervention_type, parent: argu) }

  test 'initiator should post create draft intervention' do
    sign_in initiator

    general_create(
      results: {should: true, response: :created},
      parent: :argu,
      attributes: intervention_attributes(argu_publication_attributes: {draft: true}),
      differences: [['Intervention', 1], ['Intervention.published', 0], ['Activity', 1]]
    )

    Sidekiq::Testing.inline! do
      assert_difference('Intervention.published.count' => 0, 'Activity.count' => 0) do
        employment.update(validated: true)
      end
    end
  end

  test 'initiator should post create intervention comment allowed' do
    sign_in initiator

    general_create(
      results: {should: true, response: :created},
      parent: :argu,
      attributes: intervention_attributes,
      differences: [['Intervention', 1], ['Intervention.published', 0], ['Activity', 1], ['GrantReset', 0]]
    )

    Sidekiq::Testing.inline! do
      assert_difference('Intervention.published.count' => 1, 'Activity.count' => 1) do
        employment.update(validated: true)
      end
    end
  end

  test 'initiator should post create intervention comment not allowed' do
    sign_in initiator

    general_create(
      results: {should: true, response: :created},
      parent: :argu,
      attributes: intervention_attributes(comments_allowed: :comments_not_allowed),
      differences: [['Intervention', 1], ['Intervention.published', 0], ['Activity', 1], ['GrantReset', 1]]
    )
  end

  test 'initiator should post create intervention validated employment' do
    sign_in initiator

    general_create(
      results: {should: true, response: :created},
      parent: :argu,
      attributes: intervention_attributes(employment_id: validated_employment.id),
      differences: [['Intervention', 1], ['Intervention.published', 1], ['Activity', 2]]
    )
  end

  private

  def intervention_attributes(opts = {}) # rubocop:disable Metrics/MethodLength
    {
      parent_id: intervention_type.id,
      employment_id: employment.id,
      display_name: 'Name',
      description: 'Description',
      goal: 'Goal',
      additional_introduction_information: 'Additional introduction information',
      plans_and_procedure: [:usability],
      risk_reduction: [:change_knowledge],
      continuous: [:is_continuous],
      independent: [:fully_independent],
      management_involvement: [:management_very_important],
      training_required: [:training_is_required],
      nature_of_costs: [:purchase_of_license],
      one_off_costs: :one_off_normal,
      recurring_costs: :recurring_normal,
      cost_explanation: 'Cost explanation',
      effectivity_research_method: :effectivity_internal_research,
      security_improved: :small_security_improvement,
      security_improvement_reason: 'Security improvement reason',
      business_section: :full_business,
      business_section_employees: :business_section_100_249,
      comments_allowed: :comments_are_allowed,
      contact_allowed: :contact_is_allowed
    }.merge(opts)
  end
end
