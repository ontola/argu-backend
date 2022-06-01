# frozen_string_literal: true

# Shared helper method across TestUnit and RSpec
module Argu
  module TestHelpers
    module SliceHelperMethods
      include Empathy::EmpJson::Helpers::Primitives

      def expect_slice_subjects(slice, *subjects, partial_match: false)
        iris = subjects.map { |subject| (subject.try(:iri) || subject).to_s }
        iris.each { |iri| assert_includes(slice.keys, iri) }

        return if partial_match

        assert_equal(
          subjects.count,
          slice.keys.count,
          "Found additional subjects: #{slice.keys - iris}"
        )
      end

      def expect_slice_attribute(slice, subject, predicate, object)
        values = values_from_slice(slice, subject, predicate)

        if object.nil?
          assert_nil(values)
        else
          expected = normalise_slice_expectations(object)
          record = record_from_slice(slice, subject)
          message = "Expected #{subject} to have field #{predicate} with value #{expected}: #{record}"
          assert_equal(values, expected, message)
        end
      end

      def normalise_slice_expectations(values)
        normalise_slice_values(
          values.is_a?(Array) ? values.map { |v| primitive_to_value(v) } : primitive_to_value(values)
        )
      end

      def normalise_slice_values(values)
        values.is_a?(Array) ? values.map(&:with_indifferent_access) : values&.with_indifferent_access
      end

      # Returns a normalised fields array for a record from a slice.
      def values_from_slice(slice, id, field)
        values = field_from_slice(slice, id, field)

        normalise_slice_values(values)
      end

      # Returns the fields for a record from a slice.
      def field_from_slice(slice, id, field)
        record_from_slice(slice, id)[field.to_s]&.compact
      end

      # Returns a record from a slice.
      def record_from_slice(slice, id)
        slice[(id.try(:iri) || id).to_s]
      end
    end
  end
end
