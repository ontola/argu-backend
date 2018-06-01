# frozen_string_literal: true

require 'test_helper'

class EdgeTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second')

  test 'Ltree path' do
    assert_raises(RuntimeError) { Edge.path_array('1.2.3') }
    assert_raises(RuntimeError) { Edge.path_array(Edge.all) }
    assert_equal Edge.path_array([]), 'NULL'
    assert_equal Edge.path_array(argu.self_and_descendants),
                 "ARRAY['#{argu.id}.*'::lquery] AND edges.root_id = '#{argu.root_id}'"
    assert_equal Edge.path_array(argu.descendants),
                 "ARRAY['#{freetown.path}.*'::lquery,'#{second.path}.*'::lquery] AND edges.root_id = '#{argu.root_id}'"
  end
end
