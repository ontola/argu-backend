# frozen_string_literal: true

class InviteSerializer < BaseSerializer
  attribute :addresses, predicate: NS.argu[:emailAddresses], datatype: NS.xsd.string
  has_one :edge, predicate: NS.schema.isPartOf
  attribute :granted_groups_iri, predicate: NS.argu[:grantedGroups]
  attribute :send_mail, predicate: NS.argu[:sendMail], datatype: NS.xsd.boolean
  attribute :creator, predicate: NS.schema.creator, datatype: NS.xsd.string
  attribute :group_id, predicate: NS.argu[:group], datatype: NS.xsd.string
  attribute :root_id, predicate: NS.argu[:rootId], datatype: NS.xsd.string
  attribute :redirect_url, predicate: NS.ontola[:redirectUrl], datatype: NS.xsd.string
  attribute :message, predicate: NS.argu[:message], datatype: NS.xsd.string
  attribute :max_usages, predicate: NS.argu[:maxUsages]
  attribute :expires_at, predicate: NS.argu[:expiresAt]
  enum :token_type, predicate: NS.argu[:tokenType]
end
