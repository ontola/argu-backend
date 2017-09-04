# frozen_string_literal: true

require 'test_helper'

class IriHelperTest < ActiveSupport::TestCase
  include IRIHelper
  define_freetown

  test 'should find forum by its iri' do
    resource_from_iri(argu_url('/freetown'))
  end

  test 'should find forum by its cannonical iri' do
    resource_from_iri(argu_url("/f/#{freetown.id}"))
  end

  test 'should not find forum by non existing iri' do
    assert_raises ActiveRecord::RecordNotFound do
      resource_from_iri(argu_url('/non_existent'))
    end
  end
end
