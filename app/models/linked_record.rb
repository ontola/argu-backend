# frozen_string_literal: true
class LinkedRecord < ApplicationRecord
  include Parentable, Ldable

  belongs_to :page
  belongs_to :source
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  alias_attribute :display_name, :title

  before_save :fetch_record
  validates :iri, presence: true, uniqueness: true
  validates :page, presence: true
  validates :source, presence: true

  contextualize_with_id(&:iri)
  contextualize :title, as: 'schema:name'

  parentable :source

  def fetch_record
    response = JSON.parse(HTTParty.get(iri).body)
    self.title = response['title']
  end
end
