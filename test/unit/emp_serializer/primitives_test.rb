# frozen_string_literal: true

require 'unit_test_helper'

class PrimitivesTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
  include Empathy::EmpJson::Helpers::Primitives

  test 'object_to_value serializes sequences' do
    value = LinkedRails::Sequence.new([], scope: false)
    exp = {
      type: 'lid',
      v: "_:#{value.id.id}"
    }
    assert_equal exp, object_to_value(value)
  end

  test 'object_to_value serializes RDF::List' do
    value = RDF::List.new
    exp = {
      type: 'id',
      v: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#nil'
    }
    assert_equal exp, object_to_value(value.subject)
  end

  test 'object_to_value serializes resource classes' do
    value = MediaObject
    exp = {
      type: 'id',
      v: 'http://schema.org/MediaObject'
    }
    assert_equal exp, object_to_value(value)
  end

  test 'primitive_to_value serializes globalId' do
    value = 'https://example.com/foo'
    exp = {
      type: 'id',
      v: value
    }
    assert_equal exp, primitive_to_value(RDF::URI(value))
    assert_equal exp, primitive_to_value(URI(value))
  end

  test 'primitive_to_value serializes localId' do
    value = RDF::Node.new
    exp = {
      type: 'lid',
      v: "_:#{value.id}"
    }
    assert_equal exp, primitive_to_value(value)
  end

  test 'primitive_to_value serializes symbols' do
    value = :symbolName
    exp = {
      type: 's',
      v: value.to_s
    }
    assert_equal exp, primitive_to_value(value)
  end

  test 'primitive_to_value serializes booleans' do
    truthy = true
    exp = {
      type: 'b',
      v: 'true'
    }
    assert_equal exp, primitive_to_value(truthy)

    falsy = false
    exp = {
      type: 'b',
      v: 'false'
    }
    assert_equal exp, primitive_to_value(falsy)
  end

  test 'primitive_to_value serializes strings' do
    value = 'a string'
    exp = {
      type: 's',
      v: value
    }
    assert_equal exp, primitive_to_value(value)
  end

  test 'primitive_to_value serializes datetime' do
    value = Time.zone.parse('2022-01-01T12:34Z')
    exp = {
      type: 'dt',
      v: '2022-01-01T12:34:00Z'
    }
    assert_equal exp, primitive_to_value(value)

    # Perhaps this should be normalized to the same format
    value2 = DateTime.parse('2022-01-01T12:34Z')
    exp2 = {
      type: 'dt',
      v: '2022-01-01T12:34:00+00:00'
    }
    assert_equal exp2, primitive_to_value(value2)
  end

  test 'primitive_to_value serializes numbers' do
    int = 3
    exp = {
      type: 'i',
      v: '3'
    }
    assert_equal exp, primitive_to_value(int)

    neg_int = -3
    exp = {
      type: 'i',
      v: '-3'
    }
    assert_equal exp, primitive_to_value(neg_int)

    long = 3_000_000_000_000
    exp = {
      type: 'l',
      v: '3000000000000'
    }
    assert_equal exp, primitive_to_value(long)

    bigint = 20_000_000_000_000_000_000
    exp = {
      type: 'p',
      dt: 'http://www.w3.org/2001/XMLSchema#integer',
      v: '20000000000000000000'
    }
    assert_equal exp, primitive_to_value(bigint)

    big_decimal = BigDecimal('20.000000000000000001')
    exp = {
      type: 'p',
      dt: 'http://www.w3.org/2001/XMLSchema#decimal',
      v: '20.000000000000000001'
    }
    assert_equal exp, primitive_to_value(big_decimal)

    float = 3.2
    exp = {
      type: 'd',
      v: '3.2'
    }
    assert_equal exp, primitive_to_value(float)
  end

  test 'primitive_to_value serializes langstring' do
    value = RDF::Literal('name', language: 'en')
    exp = {
      type: 'ls',
      l: 'en',
      v: 'name'
    }
    assert_equal exp, primitive_to_value(value)
  end

  test 'primitive_to_value serializes rdf string' do
    value = RDF::Literal('name')
    exp = {
      type: 's',
      v: 'name'
    }
    assert_equal exp, primitive_to_value(value)
  end

  test 'primitive_to_value serializes LinkedRails::Models which inherit from RDF::Node' do
    value = LinkedRails::Collection::FilterOption.new
    exp = {
      type: 'lid',
      v: "_:#{value.id}"
    }
    assert_equal exp, primitive_to_value(value)
  end

  test 'primitive_to_value throws on unknown ruby values' do
    value = class Foo; end
    assert_raises('unknown ruby object') do
      primitive_to_value(value)
    end
  end
end
