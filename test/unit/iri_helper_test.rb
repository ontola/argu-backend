# frozen_string_literal: true

require 'test_helper'

class IriHelperTest < ActiveSupport::TestCase
  define_freetown
  let!(:example_page) { create(:page, iri_prefix: 'example.com') }
  let!(:example) { create_forum(parent: example_page, url: :example) }
  let(:question) { create(:question, parent: freetown) }
  let(:user) { create(:user) }

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

    assert_not LinkedRails.iri_mapper.resource_from_iri(argu_url('/non_existent'), nil).present?
  end

  test 'should not find forum by non existing iri bang' do
    ActsAsTenant.current_tenant = argu

    assert_raises ActiveRecord::RecordNotFound do
      LinkedRails.iri_mapper.resource_from_iri!(argu_url('/non_existent'), nil)
    end
  end

  test 'should find example.com by its iri with slash' do
    resource_from_path(example_page, '/', example_page)
  end

  test 'should find example.com by its iri without slash' do
    resource_from_path(example_page, '', example_page)
  end

  test 'should find forum of example.com' do
    resource_from_path(example, '/example', example_page)
    ActsAsTenant.with_tenant(example_page) do
      assert_equal example, LinkedRails.iri_mapper.resource_from_iri!('https://example.com/example', nil)
    end
  end

  test 'should get opts from motion iri' do
    iri = "https://#{argu.iri_prefix}/m/1?foo=bar&arr[]=1&arr[]=2"

    ActsAsTenant.with_tenant(argu) do
      assert_equal(
        Argu::IRIMapper.opts_from_iri(iri),
        {
          action: 'show',
          params: {
            arr: %w[1 2],
            foo: 'bar',
            id: '1'
          },
          iri: iri,
          class: Motion
        }.with_indifferent_access
      )
    end
  end

  test 'should find PageCollection of user' do
    resource_from_path(user.favorite_page_collection, "/u/#{user.id}/o", argu)
  end

  test 'should find PageCollection view of user' do
    resource_from_path(user.favorite_page_collection.default_view, "/u/#{user.id}/o?page=1", argu)
  end

  test 'should find root Motion collection' do
    resource_from_path(Motion.root_collection, '/m', argu)
  end

  test 'should find root Motion collection view' do
    resource_from_path(Motion.root_collection.default_view, '/m?page=1', argu)
  end

  test 'should find nested root Motion collection' do
    resource_from_path(question.motion_collection, "/q/#{question.fragment}/m", argu)
  end

  test 'should find nested root Motion collection view' do
    resource_from_path(question.motion_collection.default_view, "/q/#{question.fragment}/m?page=1", argu)
  end

  test 'should find new action on /new' do
    resource_from_path(question.motion_collection.action(:create), "/q/#{question.fragment}/m/new", argu)
  end

  test 'should find new action on /actions/create' do
    resource_from_path(question.motion_collection.action(:create), "/q/#{question.fragment}/m/actions/create", argu)
  end

  private

  def freetown_from_path(path)
    resource_from_path(freetown, path)
  end

  def resource_from_path(resource, path, root = argu)
    ActsAsTenant.with_tenant(root) do
      assert_equal(
        LinkedRails.iri_mapper.resource_from_iri("#{root.iri}#{path}", nil).iri,
        resource.iri
      )
    end
  end
end
