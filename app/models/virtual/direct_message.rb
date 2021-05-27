# frozen_string_literal: true

class DirectMessage < VirtualResource
  include Parentable

  parentable :resource

  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :actor, :body, :subject, :email_address
  attr_writer :resource, :resource_iri

  validates :actor, presence: true
  validates :body, presence: true
  validates :email_address, presence: true
  validates :resource, presence: true
  validates :resource_iri, presence: true
  validates :subject, presence: true

  delegate :root, to: :resource

  def edgeable_record
    resource
  end

  def identifier
    "#{resource.identifier}_dm"
  end

  def canonical_iri_opts
    {parent_iri: split_iri_segments(resource.iri_path)}
  end

  def iri_opts
    {parent_iri: split_iri_segments(resource.iri_path)}
  end

  def email_address_id=(value)
    if value.to_s.include?('/email_addresses/')
      self.email_address = EmailAddress.find(URI(value).path.split('/email_addresses/').last)
    elsif value.is_a?(String)
      self.email_address = EmailAddress.find_by(email: value)
    end
  end

  def email_address_id
    email_address&.iri
  end

  def resource_iri
    @resource_iri ||= resource.iri
  end

  def resource
    @resource ||= LinkedRails.iri_mapper.resource_from_iri(@resource_iri)
  end

  def send_email! # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    Argu::API.service_api.create_email(
      :direct_message,
      resource.publisher,
      actor: {
        display_name: actor.display_name,
        iri: actor.profileable.iri,
        thumbnail: actor.profileable.default_profile_photo.thumbnail
      },
      body: body,
      email: email_address.email,
      resource: {
        display_name: resource.display_name,
        iri: resource.iri
      },
      subject: subject
    )
  end

  class << self
    def attributes_for_new(opts)
      user = opts[:user_context]&.user
      confirmed_email_addresses = user&.email_addresses&.confirmed || []
      {
        actor: user&.iri,
        email_address_id: confirmed_email_addresses.any? ? user.primary_email_record.iri : nil,
        resource: opts[:parent]
      }
    end
  end
end
