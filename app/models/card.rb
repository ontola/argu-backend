class Card < ActiveRecord::Base
  has_many :card_pages, -> { order(:page_index) }
  accepts_nested_attributes_for :card_pages

  attr_accessor :pages_index

  #attr_accessible :title, :url, :tag, :card_pages_attributes
end