# frozen_string_literal: true

class VoteMatch < ApplicationRecord
  enhance Createable
  enhance Destroyable
  enhance Updateable

  include Listable

  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  has_many_list_items :voteables
  has_many_list_items :vote_comparables

  validates :shortname,
            allow_nil: true,
            length: {minimum: 4, maximum: 75},
            uniqueness: {scope: :creator_id},
            format: {with: /\A[_a-zA-Z0-9]*\z/i}
  validates :publisher, :creator, presence: true
  validates :name, length: {minimum: 5, maximum: 75}
  validates :text, length: {maximum: 5000}

  alias_attribute :display_name, :name

  def self.anonymize(collection)
    collection.update_all(creator_id: Profile::COMMUNITY_ID)
  end

  def self.expropriate(collection)
    collection.update_all(publisher_id: User::COMMUNITY_ID)
  end

  def parent
    creator.profileable
  end
end
