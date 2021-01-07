# frozen_string_literal: true

class OtpAttemptSerializer < BaseSerializer
  attribute :otp_attempt, predicate: LinkedRails.app_ns[:otp], datatype: RDF::XSD[:integer], if: method(:never)
end
