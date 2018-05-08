# frozen_string_literal: true

require 'test_helper'

class EdgesControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # Show
  ####################################
  test 'should redirect to owner with id' do
    get :show, params: {format: :json_api, id: motion.edge.id}
    assert_redirected_to motion.iri_path
  end

  test 'should redirect to owner with uuid' do
    get :show, params: {format: :json_api, id: motion.edge.uuid}
    assert_redirected_to motion.iri_path
  end
end
