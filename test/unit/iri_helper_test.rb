# frozen_string_literal: true

require 'test_helper'

class IriHelperTest < ActiveSupport::TestCase
  include IRIHelper
  define_freetown

  test 'should find forum by its iri' do
    assert_equal resource_from_iri(argu_url("/#{freetown.parent.url}/freetown")), freetown
  end

  test 'should find forum by a subview iri' do
    assert_equal resource_from_iri(argu_url("/#{freetown.parent.url}/freetown/edit")), freetown
  end

  test 'should find forum by a subview iri with upcase shortname' do
    assert_equal resource_from_iri(argu_url("/#{freetown.parent.url}/Freetown/edit")), freetown
  end

  test 'should find forum by its cannonical iri' do
    assert_equal resource_from_iri(argu_url("/edges/#{freetown.uuid}")), freetown
  end

  test 'should not find forum by non existing iri' do
    assert_not resource_from_iri(argu_url('/non_existent')).present?
  end

  test 'should not find forum by non existing iri bang' do
    assert_raises ActiveRecord::RecordNotFound do
      resource_from_iri!(argu_url('/non_existent'))
    end
  end
end
