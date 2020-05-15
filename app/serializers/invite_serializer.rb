# frozen_string_literal: true

class InviteSerializer < BaseSerializer
  attribute :addresses, predicate: NS::ARGU[:emailAddresses], datatype: NS::XSD[:string], if: method(:never)
  attribute :send_mail, predicate: NS::ARGU[:sendMail], datatype: NS::XSD[:boolean], if: method(:never)
  attribute :creator, predicate: NS::SCHEMA[:creator], datatype: NS::XSD[:string], if: method(:never)
  attribute :group_id, predicate: NS::ARGU[:groupId], datatype: NS::XSD[:string], if: method(:never)
  attribute :root_id, predicate: NS::ARGU[:rootId], datatype: NS::XSD[:string], if: method(:never)
  attribute :redirect_url, predicate: NS::ARGU[:redirectUrl], datatype: NS::XSD[:string], if: method(:never)
  attribute :message, predicate: NS::ARGU[:message], datatype: NS::XSD[:string], if: method(:never)
end
