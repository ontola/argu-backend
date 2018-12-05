# frozen_string_literal: true

require 'argu/api'

class DirectMessage
  include ActiveModel::Model
  include RailsLD::Model
  include ApplicationModel
  include IRIHelper

  enhance Actionable
  enhance Createable

  attr_accessor :actor, :body, :subject
  attr_reader :email
  attr_writer :resource, :resource_iri
  validates :actor, presence: true
  validates :body, presence: true
  validates :email, presence: true
  validates :resource, presence: true
  validates :resource_iri, presence: true
  validates :subject, presence: true

  alias read_attribute_for_serialization send
  delegate :root, to: :resource

  def edgeable_record
    resource
  end

  def identifier
    "#{resource.identifier}_dm"
  end

  def iri_opts
    {parent_iri: resource.iri_path}
  end

  def email=(value)
    if value.include?('/email_addresses/')
      value = EmailAddress.find(URI(value).path.gsub('/email_addresses/', '')).email
    end
    @email = value
  end

  def new_record?
    true
  end

  def resource_iri
    @resource_iri ||= resource.iri
  end

  def resource
    @resource ||= resource_from_iri(@resource_iri)
  end

  def send_email! # rubocop:disable Metrics/AbcSize
    Argu::API.service_api.create_email(
      :direct_message,
      resource.publisher,
      actor: {
        display_name: actor.display_name,
        iri: actor.profileable.iri,
        thumbnail: actor.default_profile_photo.thumbnail
      },
      body: body,
      email: email,
      resource: {
        display_name: resource.display_name,
        iri: resource.iri
      },
      subject: subject
    )
  end
end
