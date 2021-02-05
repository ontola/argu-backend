# frozen_string_literal: true

class BudgetShop < Discussion
  enhance Offerable

  include Edgeable::Content

  property :budget_max, :integer, NS::ARGU[:budgetMax]
  property :currency, :string, NS::SCHEMA.priceCurrency, default: 'EUR'
  parentable :container_node, :page, :phase

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}

  def cart_for(user)
    @cart ||= Cart.new(shop: self, user: user)
  end

  class << self
    def iri
      [super, NS::ARGU[:Shop]]
    end
  end
end
