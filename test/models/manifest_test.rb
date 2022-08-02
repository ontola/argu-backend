# frozen_string_literal: true

require 'test_helper'

class ManifestTest < ActiveSupport::TestCase
  let!(:page) { create_page(iri_prefix: 'example.com', profile: build(:profile, name: 'test')) }

  test 'should store and update manifest' do
    assert_equal('#2d707f', get_manifest('http://example.com')[:theme_color])
    page.update(primary_color: '#FFFFFF')
    assert_equal('#FFFFFF', get_manifest('http://example.com')[:theme_color])
  end

  test 'should update iri_prefix of manifest' do
    assert(get_manifest('http://example.com'))
    page.update(iri_prefix: 'example.com/path')
    assert_equal('#2d707f', get_manifest('http://example.com/path')[:theme_color])
    assert_nil(get_manifest('http://example.com'))
  end

  test 'should clean up manifest' do
    assert(get_manifest('http://example.com'))
    page.destroy
    assert_nil(get_manifest('http://example.com'))
  end

  private

  def get_manifest(iri)
    raw = LinkedRails::Manifest.redis_client.hget(LinkedRails::Manifest::MANIFEST_KEY, iri)

    JSON.parse(raw).with_indifferent_access if raw
  end
end
