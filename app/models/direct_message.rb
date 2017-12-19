# frozen_string_literal: true

require 'argu/api'

class DirectMessage
  include ActiveModel::Model
  include IRIHelper

  attr_accessor :actor, :body, :email, :subject
  attr_writer :resource, :resource_iri
  validates :actor, presence: true
  validates :body, presence: true
  validates :email, presence: true
  validates :resource, presence: true
  validates :resource_iri, presence: true
  validates :subject, presence: true

  def new_record?
    true
  end

  def resource_iri
    @resource_iri ||= resource.iri
  end

  def resource
    @resource ||= resource_from_iri(@resource_iri)
  end

  def send_email!
    Argu::API.service_api.create_email(
      :direct_message,
      resource.publisher,
      actor: {
        display_name: actor.display_name,
        iri: actor.iri,
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
