# frozen_string_literal: true

require 'test_helper'

class InterventionTest < ActiveSupport::TestCase
  define_page
  let(:intervention_type) { create(:intervention_type, parent: argu) }
  let(:intervention) do
    intervention_type
    create(:intervention, parent: intervention_type, employment_id: create(:employment, parent: argu).id)
  end

  test 'Assign effects as symbol' do
    intervention
    assert_equal intervention.effects, [NS::ONTOLA['form_option/plans_and_procedure/usability']]
    intervention.update!(people_and_resources: :resources)
    expected = [
      NS::ONTOLA['form_option/plans_and_procedure/usability'],
      NS::ONTOLA['form_option/people_and_resources/resources']
    ]
    assert_equal intervention.effects, expected
    assert_equal intervention.reload.effects, expected
  end
end
