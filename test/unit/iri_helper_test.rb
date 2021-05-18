# frozen_string_literal: true

require 'test_helper'

class IriHelperTest < ActiveSupport::TestCase
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

  test 'should find forum by its iri with upcase shortname' do
    freetown_from_path('/Freetown')
  end

  test 'should find forum by its cannonical iri' do
    freetown_from_path("/edges/#{freetown.uuid}")
  end

  test 'should not find forum by non existing iri' do
    ActsAsTenant.current_tenant = argu

    assert_not LinkedRails.resource_from_iri(argu_url('/non_existent')).present?
  end

  test 'should not find forum by non existing iri bang' do
    ActsAsTenant.current_tenant = argu

    assert_raises ActiveRecord::RecordNotFound do
      LinkedRails.resource_from_iri!(argu_url('/non_existent'))
    end
  end

  test 'should find example.com by its iri with slash' do
    resource_from_path(example_page, '/')
  end

  test 'should find example.com by its iri without slash' do
    resource_from_path(example_page, '')
  end

  test 'should find forum of example.com' do
    ActsAsTenant.current_tenant = example_page

    resource_from_path(example, '/example')
    assert_equal example, LinkedRails.resource_from_iri!('https://example.com/example')
  end

  private

  def freetown_from_path(path)
    resource_from_path(freetown, path)
  end

  def resource_from_path(resource, path)
    ActsAsTenant.with_tenant(resource.root) do
      assert_equal(LinkedRails.resource_from_iri("#{resource.root.iri}#{path}"), resource)
    end
  end
end
