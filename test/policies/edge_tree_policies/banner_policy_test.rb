# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class BannerPolicyTest < PolicyTest
  include DefaultPolicyTests
  subject do
    create(:banner,
           audience: Banner.audiences[:everyone],
           forum: freetown,
           title: 'title',
           content: 'content')
  end

  generate_crud_tests

  private

  def destroy_results
    nobody_results.merge(super_admin: true, staff: true)
  end

  def update_results
    nobody_results.merge(super_admin: true, staff: true)
  end

  def create_results
    nobody_results.merge(super_admin: true, staff: true)
  end
end
