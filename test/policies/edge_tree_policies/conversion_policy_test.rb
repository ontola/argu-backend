# frozen_string_literal: true

require 'test_helper'
class ConversionPolicyTest < Argu::TestHelpers::PolicyTest
  subject { Conversion.new(edge: motion, klass_iri: Question.iri) }
  let(:invalid_edge_subject) { Conversion.new(edge: pro_argument, klass_iri: Motion.iri) }
  let(:invalid_klass_subject) { Conversion.new(edge: motion, klass_iri: Argument.iri) }

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
