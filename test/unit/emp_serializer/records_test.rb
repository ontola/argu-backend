# frozen_string_literal: true

require 'unit_test_helper'

class RecordsTest < ActiveSupport::TestCase
  include Empathy::EmpJson::Helpers::Slices
  include Empathy::EmpJson::Helpers::Primitives

  Model = Struct.new(:iri)

  test 'record_id handles URI from bulk_controller' do
    id = URI('https://example.com/foo')
    slice = {}
    exp = {
      _id: {
        type: 'id',
        v: id.to_s
      }
    }
    add_record_to_slice(slice, Model.new(id))

    assert_equal exp, slice[id.to_s]
  end

  test 'add_record_to_slice initialises globalId' do
    id = RDF::URI('https://example.com/foo')
    slice = {}
    exp = {
      _id: {
        type: 'id',
        v: id.to_s
      }
    }
    add_record_to_slice(slice, Model.new(id))

    assert_equal exp, slice[id.to_s]
  end

  test 'add_record_to_slice initialises localId' do
    id = RDF::Node.new
    slice = {}
    exp = {
      _id: {
        type: 'lid',
        v: "_:#{id.id}"
      }
    }
    add_record_to_slice(slice, Model.new(id))

    assert_equal exp, slice[id.to_s]
  end
end
