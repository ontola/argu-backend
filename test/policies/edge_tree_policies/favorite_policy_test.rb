# frozen_string_literal: true

require 'test_helper'
class FavoritePolicyTest < Argu::TestHelpers::PolicyTest
  include Argu::TestHelpers::DefaultPolicyTests
  let(:subject) { create(:favorite, user: creator, edge: freetown) }

  generate_crud_tests

  private

  def create_results
    everybody_results.merge(non_member: false)
  end

  def destroy_results
    nobody_results.merge(creator: true)
  end

  def update_results
    nobody_results.merge(staff: true)
  end
end
