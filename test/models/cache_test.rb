# frozen_string_literal: true

require 'test_helper'

class CacheTest < ActiveSupport::TestCase
  define_helsinki
  define_holland

  test 'write helsinki to cache' do
    file = Argu::Cache.new(directory: Rails.root.join('tmp/cache_test')).write(helsinki, :hex_adapter, :hndjson)

    assert_includes(
      File.read(file),
      Oj.fast_generate(
        HexAdapter.new(nil).send(
          :rdf_array_to_hex,
          [
            helsinki.iri,
            NS::SCHEMA[:name],
            helsinki.display_name,
            NS::LL[:supplant]
          ]
        )
      )
    )
  end
end
