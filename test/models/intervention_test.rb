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
    ActsAsTenant.with_tenant(argu) do
      intervention
      assert_equal intervention.effects, [
        LinkedRails.iri(path: '/argu/enums/interventions/plans_and_procedure', fragment: :usability)
      ]
      intervention.update!(people_and_resources: :resources)
      expected = [
        LinkedRails.iri(path: '/argu/enums/interventions/plans_and_procedure', fragment: :usability),
        LinkedRails.iri(path: '/argu/enums/interventions/people_and_resources', fragment: :resources)
      ]
      assert_equal intervention.effects, expected
      assert_equal intervention.reload.effects, expected
    end
  end
end
