# frozen_string_literal: true
class GuestUser
  include ActiveModel::Model, Ldable
  attr_accessor :session, :id

  contextualize_as_type 'schema:Person'
  contextualize_with_id { |r| "https://#{Rails.application.config.host}/sessions/#{r.id}" }
  contextualize :display_name, as: 'schema:name'

  def access_tokens
    []
  end

  def association(association)
    return unless association == :profile
    ActiveRecord::Associations::HasOneAssociation.new(self, GuestUser._reflect_on_association(association))
  end

  def self.base_class
    ActiveRecord::Base
  end

  def display_name
    I18n.t('users.guest')
  end

  def id
    @id ||= session.id
  end

  def self.pluralize_table_names
    false
  end

  def self.primary_key
    :id
  end

  def profile
    @profile ||= Profile.new(profileable: self)
  end

  def _read_attribute(attribute)
    send(attribute)
  end

  def self._reflect_on_association(association)
    ActiveRecord::Reflection::HasOneReflection.new(:profile, nil, {as: :profileable}, self) if association == :profile
  end
end
