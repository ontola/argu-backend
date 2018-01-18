# frozen_string_literal: true

require 'test_helper'

class EdgeTest < ActiveSupport::TestCase
  define_freetown

  test 'Ltree path' do
    assert_raises(RuntimeError) { Edge.path_array('1.2.3') }
    assert_equal Edge.path_array([]), 'NULL'
    assert_equal Edge.path_array(Edge.all),
                 "ARRAY['#{Page.first.edge.id}.*'::lquery,'#{freetown.page.edge.id}.*'::lquery]"
  end
end
