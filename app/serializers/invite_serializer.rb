# frozen_string_literal: true

class InviteSerializer < BaseSerializer
  attribute :addresses, predicate: NS.argu[:emailAddresses], datatype: NS.xsd.string
  attribute :send_mail, predicate: NS.argu[:sendMail], datatype: NS.xsd.boolean
  attribute :creator, predicate: NS.schema.creator, datatype: NS.xsd.string
  attribute :group_id, predicate: NS.argu[:groupId], datatype: NS.xsd.string
  attribute :root_id, predicate: NS.argu[:rootId], datatype: NS.xsd.string
  attribute :redirect_url, predicate: NS.ontola[:redirectUrl], datatype: NS.xsd.string
  attribute :message, predicate: NS.argu[:message], datatype: NS.xsd.string
end
