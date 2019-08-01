# frozen_string_literal: true

require 'test_helper'

class IriHelperTest < ActiveSupport::TestCase
  include IRIHelper
  define_freetown

  test 'should find forum by its iri' do
    freetown_from_path('/freetown')
  end

  test 'should find forum by a subview iri' do
    freetown_from_path('/freetown/edit')
  end

  test 'should find forum by a subview iri with upcase shortname' do
    freetown_from_path('/Freetown/edit')
  end

  test 'should find forum by its cannonical iri' do
    freetown_from_path("/edges/#{freetown.uuid}")
  end

  test 'should not find forum by non existing iri' do
    assert_not resource_from_iri(argu_url('/non_existent')).present?
  end

  test 'should not find forum by non existing iri bang' do
    assert_raises ActiveRecord::RecordNotFound do
      resource_from_iri!(argu_url('/non_existent'))
    end
  end

  def freetown_from_path(path)
    assert_equal resource_from_iri(argu_url("/#{freetown.parent.url}#{path}", frontend: false)), freetown
    assert_equal resource_from_iri(argu_url("/#{freetown.parent.url}#{path}", frontend: true)), freetown
  end
end
