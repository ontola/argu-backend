# frozen_string_literal: true

require 'test_helper'

class EdgeTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second')
  let(:second_page) { create(:page) }
  let(:motion) { create(:motion, parent: freetown) }

  test 'iri' do
    assert_equal motion.canonical_iri(only_path: true), "/edges/#{motion.uuid}"
    assert_equal motion.iri_path, "/#{argu.url}/m/#{motion.fragment}"
  end

  test 'Ltree path' do
    assert_raises(RuntimeError) { Edge.path_array('1.2.3') }
    assert_raises(RuntimeError) { Edge.path_array(Edge.all) }
    assert_equal Edge.path_array([]), 'NULL'
    assert_equal Edge.path_array(argu.self_and_descendants),
                 "ARRAY['#{argu.id}.*'::lquery] AND edges.root_id = '#{argu.root_id}'"
    assert_includes(
      [
        "ARRAY['#{freetown.path}.*'::lquery,'#{second.path}.*'::lquery] AND edges.root_id = '#{argu.root_id}'",
        "ARRAY['#{second.path}.*'::lquery,'#{freetown.path}.*'::lquery] AND edges.root_id = '#{argu.root_id}'"
      ],
      Edge.path_array(argu.descendants)
    )
  end

  test 'property destruction' do
    assert_not_nil freetown.default_decision_group
    second_page.destroy
    assert_not_nil freetown.reload.default_decision_group
  end
end
