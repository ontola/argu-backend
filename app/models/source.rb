# frozen_string_literal: true
class Source < ApplicationRecord
  include Parentable

  belongs_to :page, inverse_of: :sources
  has_many :linked_records
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  alias_attribute :display_name, :name
  alias_attribute :url, :shortname

  validates :shortname, presence: true, length: {minimum: 4, maximum: 75}, uniqueness: {scope: :page_id}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :page, presence: true

  before_update :reset_public_grant, if: :visibility_changed?

  # @!attribute visibility
  # @return [Enum] The visibility of the {Source}
  enum visibility: {open: 1, closed: 2, hidden: 3}

  parentable :page

  # @private
  attr_accessor :tab, :active

  def page=(value)
    super value.is_a?(Page) ? value : Page.find_via_shortname(value)
  end

  def to_param
    shortname
  end
end
