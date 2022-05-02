# frozen_string_literal: true

require 'unit_test_helper'

class RecordsTest < ActiveSupport::TestCase
  include LinkedRails::EmpJSON::Records
  include LinkedRails::EmpJSON::Primitives

  Model = Struct.new(:iri)

  test 'record_id handles URI from bulk_controller' do
    value = URI('https://example.com/bar')

    assert_equal 'https://example.com/bar', record_id(value)
  end

  test 'create_record initialises globalId' do
    id = RDF::URI('https://example.com/foo')
    slice = {}
    exp = {
      _id: {
        type: 'id',
        v: id.to_s
      }
    }
    create_record(slice, Model.new(id))

    assert_equal exp, slice[id.to_s]
  end

  test 'create_record initialises localId' do
    id = RDF::Node.new
    slice = {}
    exp = {
      _id: {
        type: 'lid',
        v: "_:#{id.id}"
      }
    }
    create_record(slice, Model.new(id))

    assert_equal exp, slice[id.to_s]
  end
end
