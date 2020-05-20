# frozen_string_literal: true

require 'test_helper'

class CacheTest < ActiveSupport::TestCase
  define_helsinki
  define_holland

  test 'write helsinki to cache' do
    file = Argu::Cache.new(directory: Rails.root.join('tmp/cache_test')).write(helsinki, :hndjson)

    assert_includes(
      File.read(file),
      Oj.fast_generate(
        [
          helsinki.iri,
          NS::SCHEMA[:name],
          helsinki.display_name,
          NS::XSD[:string],
          '',
          NS::LL[:supplant]
        ]
      )
    )
  end
end
