# frozen_string_literal: true

require 'test_helper'

class EdgesControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }

  ####################################
  # Show
  ####################################
  test 'should redirect to owner with uuid' do
    get :show, params: {format: :json_api, id: motion.uuid}
    assert_redirected_to motion.iri
  end

  test 'should redirect to owner with uuid with other tenant' do
    ActsAsTenant.current_tenant = create(:page)
    get :show, params: {format: :json_api, id: motion.uuid}
    assert_redirected_to motion.iri
  end
end
