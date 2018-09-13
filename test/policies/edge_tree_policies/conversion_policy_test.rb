# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class ConversionPolicyTest < PolicyTest
  subject { Conversion.new(edge: motion, klass: Question) }
  let(:invalid_edge_subject) { Conversion.new(edge: pro_argument, klass: Motion) }
  let(:invalid_klass_subject) { Conversion.new(edge: motion, klass: Argument) }

  test 'create valid conversion' do
    test_policy(subject, :create, staff_only_results)
  end

  test 'create invalid edge conversion' do
    test_policy(invalid_edge_subject, :create, staff: false)
  end

  test 'create invalid klass conversion' do
    test_policy(invalid_klass_subject, :create, staff: false)
  end
end
