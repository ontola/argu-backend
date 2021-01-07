# frozen_string_literal: true

class OtpSecretSerializer < BaseSerializer
  attribute :otp_attempt, predicate: LinkedRails.app_ns[:otp], datatype: RDF::XSD[:integer], if: method(:never)
  attribute :active, predicate: LinkedRails.app_ns[:otpActive]
end
