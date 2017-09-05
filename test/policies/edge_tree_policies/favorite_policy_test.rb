# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class FavoritePolicyTest < PolicyTest
  include DefaultPolicyTests
  let(:subject) { create(:favorite, user: creator, edge: freetown.edge) }

  generate_crud_tests

  private

  def destroy_results
    nobody_results.merge(creator: true)
  end

  def update_results
    nobody_results.merge(staff: true)
  end
end
