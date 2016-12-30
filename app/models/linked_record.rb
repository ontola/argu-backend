# frozen_string_literal: true
class LinkedRecord < ApplicationRecord
  include Argumentable, Parentable, Ldable

  belongs_to :page
  belongs_to :source
  alias_attribute :display_name, :title

  before_save :fetch_record
  validates :iri, presence: true, uniqueness: true
  validates :page, presence: true
  validates :source, presence: true

  contextualize_with_id { |r| Rails.application.routes.url_helpers.linked_record_url(r, protocol: :https) }
  contextualize :title, as: 'schema:name'

  parentable :source

  def fetch_record
    response = JSON.parse(HTTParty.get(iri).body)
    self.title = response['title']
  end

  def publisher
    User.first
  end

  def creator
    Profile.first
  end
end
