# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class ExportPolicyTest < PolicyTest
  include DefaultPolicyTests
  let(:subject) { create(:export, parent: freetown, user: create(:user)) }

  generate_crud_tests

  private

  def show_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def create_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def update_results
    nobody_results.merge(staff: true)
  end

  def destroy_results
    nobody_results.merge(administrator: true, staff: true)
  end
end
