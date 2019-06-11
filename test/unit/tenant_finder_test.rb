# frozen_string_literal: true

require 'test_helper'

class TenantFinderTest < ActiveSupport::TestCase
  define_freetown
  let!(:demogemeente) { create(:page, iri_prefix: 'demogemeente.nl/test') }
  let!(:upcase_page) { create(:page, iri_prefix: 'example.com/Upcase') }

  test 'should find tenant by forum iri' do
    assert_equal TenantFinder.from_url(freetown.iri), argu
  end

  test 'should find tenant by forum iri with upcase shortname' do
    assert_equal TenantFinder.from_url(freetown.iri.to_s.gsub('freetown', 'Freetown')), argu
  end

  test 'should find tenant by forum iri with upcase page shortname' do
    assert_equal TenantFinder.from_url(freetown.iri.to_s.gsub(argu.url, argu.url.upcase)), argu
  end

  test 'should find tenant by invalid iri' do
    assert_nil TenantFinder.from_url('https://example.com/invalid')
  end

  test 'should find demogemeente' do
    assert_equal TenantFinder.from_url('https://demogemeente.nl/test'), demogemeente
  end

  test 'should find demogemeente sub url' do
    assert_equal TenantFinder.from_url('https://demogemeente.nl/test/forum'), demogemeente
  end

  test 'should find demogemeente sub url with upcase page shortname' do
    assert_equal TenantFinder.from_url('https://demogemeente.nl/Test/forum'), demogemeente
  end

  test 'should find upcase' do
    assert_equal TenantFinder.from_url('https://example.com/Upcase'), upcase_page
  end

  test 'should find upcase sub url' do
    assert_equal TenantFinder.from_url('https://example.com/Upcase/forum'), upcase_page
  end

  test 'should find upcase sub url with downcase page shortname' do
    assert_equal TenantFinder.from_url('https://example.com/upcase/forum'), upcase_page
  end
end
