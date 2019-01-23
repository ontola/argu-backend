# frozen_string_literal: true

require 'test_helper'

class EdgeTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second')
  let(:second_page) { create(:page) }
  let(:motion) { create(:motion, parent: freetown) }

  test 'iri' do
    assert_equal motion.canonical_iri_path, "/edges/#{motion.uuid}"
    assert_equal motion.iri.path, "/#{argu.url}/m/#{motion.fragment}"
  end

  test 'property destruction' do
    assert_not_nil freetown.default_decision_group
    second_page.destroy
    assert_not_nil freetown.reload.default_decision_group
  end
end
