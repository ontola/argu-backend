# frozen_string_literal: true

require 'test_helper'
class ExportPolicyTest < Argu::TestHelpers::PolicyTest
  let(:subject) { create(:export, parent: freetown, user: create(:user)) }

  test 'crud policies export' do
    test_crud_policies
  end

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
