# frozen_string_literal: true

class InviteSerializer < BaseSerializer
  attribute :addresses, predicate: NS::ARGU[:emailAddresses], datatype: NS::XSD[:string]
  attribute :send_mail, predicate: NS::ARGU[:sendMail], datatype: NS::XSD[:boolean]
  attribute :creator, predicate: NS::SCHEMA[:creator], datatype: NS::XSD[:string]
  attribute :group_id, predicate: NS::ARGU[:groupId], datatype: NS::XSD[:string]
  attribute :root_id, predicate: NS::ARGU[:rootId], datatype: NS::XSD[:string]
  attribute :redirect_url, predicate: NS::ONTOLA[:redirectUrl], datatype: NS::XSD[:string]
  attribute :message, predicate: NS::ARGU[:message], datatype: NS::XSD[:string]
end
