# frozen_string_literal: true

require 'test_helper'

class IriHelperTest < ActiveSupport::TestCase
  include IRIHelper
  define_freetown
  let!(:example_page) { create(:page, iri_prefix: 'example.com') }
  let!(:example) { create_forum(parent: example_page, url: :example) }

  test 'should find page by its iri with slash' do
    resource_from_path(argu, '/')
  end

  test 'should find page by its iri without slash' do
    resource_from_path(argu, '')
  end

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

  test 'should find example.com by its iri with slash' do
    resource_from_path(example_page, '/', old_fe: false)
  end

  test 'should find example.com by its iri without slash' do
    resource_from_path(example_page, '', old_fe: false)
  end

  test 'should find forum of example.com' do
    resource_from_path(example, '/example', old_fe: false)
    assert_equal example, resource_from_iri!('https://example.com/example')
  end

  test 'should find forum of example.com by a subview iri' do
    resource_from_path(example, '/example/edit', old_fe: false)
    assert_equal example, resource_from_iri!('https://example.com/example/edit')
  end

  private

  def freetown_from_path(path)
    resource_from_path(freetown, path)
  end

  def resource_from_path(resource, path, old_fe: true)
    assert_equal(resource_from_iri(argu_url("/#{resource.root.url}#{path}", frontend: false)), resource) if old_fe
    assert_equal(resource_from_iri("#{resource.root.iri}#{path}"), resource)
  end
end
