# frozen_string_literal: true

require 'test_helper'

class CacheTest < ActiveSupport::TestCase
  define_helsinki
  define_holland
  let(:page) { helsinki.parent }
  let(:cache) { Argu::Cache.new(directory: Rails.root.join('tmp/cache_test')) }

  test 'write page to cache' do
    ActsAsTenant.with_tenant(page) do
      assert page.write_to_cache(cache)
    end
  end

  test 'write vocabulary to cache' do
    file = ActsAsTenant.with_tenant(page) { Vocabulary.new.write_to_cache(cache) }
    assert_statement(
      file,
      NS::SCHEMA[:name],
      RDF.type,
      RDF.Property,
      'http://www.w3.org/1999/02/22-rdf-syntax-ns#namedNode',
      '',
      NS::LL[:supplant]
    )
  end

  test 'write helsinki to cache' do
    file = cache.write(helsinki, :hndjson)

    assert_statement(
      file,
      helsinki.iri,
      NS::SCHEMA[:name],
      helsinki.display_name,
      NS::XSD[:string],
      '',
      NS::LL[:supplant]
    )
  end

  private

  def assert_statement(file, *statements)
    result = File.read(file)
    statements.each do |statement|
      assert_includes(result, Oj.fast_generate(statement))
    end
  end
end
