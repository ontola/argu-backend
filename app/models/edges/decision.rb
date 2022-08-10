# frozen_string_literal: true

class Decision < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance Loggable
  enhance MarkAsImportant

  include DeltaHelper

  attribute :display_name
  property :description, :text, NS.schema.text
  property :state, :integer, NS.argu[:state], default: 0, enum: {pending: 0, approved: 1, rejected: 2}

  has_one :decision_activity,
          -> { where("key ~ '*.?'", Decision.actioned_keys.join('|').freeze) },
          foreign_key: :trackable_edge_id,
          class_name: 'Activity',
          inverse_of: :trackable,
          primary_key: :uuid

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :state, presence: true
  parentable :motion

  def added_delta
    [
      [parent.iri, NS.argu[:decision], iri, delta_iri(:replace)]
    ]
  end

  def display_name
    return self[:display_name] if destroyed?

    self[:display_name] = I18n.t("decisions.#{parent.model_name.i18n_key}.#{state}")
  end

  class << self
    # @return [Array<Symbol>] States that indicate an action was taken on this decision
    def actioned_keys
      states.keys[1..]
    end
  end
end
