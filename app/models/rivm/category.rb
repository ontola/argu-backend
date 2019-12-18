# frozen_string_literal: true

class Category < Edge
  include Edgeable::Content
  enhance Feedable
  enhance Statable
  enhance MeasureTypeable, except: [:Model]
  enhance PublicGrantable

  parentable :page, :measure_type
  validates :display_name, presence: true, length: {maximum: 110}
  validates :description, length: {maximum: 5000}

  has_many :measure_type_examples,
           primary_key_property: :category_id,
           class_name: 'measureType',
           dependent: false

  with_collection :measure_types,
                  association: :measure_type_examples,
                  default_display: :table

  def default_public_grant
    :participator
  end

  def parent_collections(user_context)
    [self.class.root_collection(user_context: user_context)]
  end

  class << self
    def iri_namespace
      NS::RIVM
    end

    def root_collection_opts
      super.merge(title: ->(_r) { I18n.t('measure_types.plural') })
    end
  end
end
