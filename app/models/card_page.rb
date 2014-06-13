class CardPage < ActiveRecord::Base
  belongs_to :card

  #attr_accessible :title, :contents, :page_index

  validates_presence_of :title
  validates_uniqueness_of :url, scope: :card_id

  before_save :generate_url
  before_save :check_page_index

  def title=(value)
    write_attribute(:title, value)
    generate_url
  end

  def url
    to_url self.title
  end

private

  def check_page_index
    if page_index.blank?
      if card.card_pages.length > 0
        self.page_index = card.card_pages.last.page_index + 1
      else
        self.page_index = 0
      end
    end
  end

  def generate_url
    write_attribute(:url, to_url(self.title))
  end

  def to_url(value)
    value.to_s.downcase.strip.gsub(/\s+/, '-')
  end

end