# frozen_string_literal: true

require 'test_helper'

class EdgeTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }

  test 'iri' do
    assert_equal motion.iri.path, "/#{argu.url}/m/#{motion.fragment}"
  end
end
