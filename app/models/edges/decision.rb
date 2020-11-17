# frozen_string_literal: true

class Decision < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance Loggable
  enhance MarkAsImportant
  enhance LinkedRails::Enhancements::Menuable
  enhance LinkedRails::Enhancements::Updatable

  attribute :display_name
  property :description, :text, NS::SCHEMA[:text]
  property :forwarded_group_id, :integer, NS::ARGU[:forwardedGroup]
  property :forwarded_user_id, :integer, NS::ARGU[:forwardedUser]
  property :state, :integer, NS::ARGU[:state], default: 0, enum: {pending: 0, approved: 1, rejected: 2, forwarded: 3}
  property :step, :integer, NS::ARGU[:step]

  belongs_to :forwarded_group, class_name: 'Group', foreign_key_property: :forwarded_group_id
  belongs_to :forwarded_user, class_name: 'User', foreign_key_property: :forwarded_user_id
  has_one :decision_activity,
          -> { where("key ~ '*.?'", Decision.actioned_keys.join('|').freeze) },
          foreign_key: :trackable_edge_id,
          class_name: 'Activity',
          inverse_of: :trackable,
          primary_key: :uuid

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validate :correctly_forwarded, if: :forwarded?
  validates :state, presence: true
  parentable :motion

  def added_delta
    [
      [parent.iri, NS::ARGU[:decision], iri, delta_iri(:replace)]
    ]
  end

  def display_name
    return self[:display_name] if destroyed?

    self[:display_name] = I18n.t("decisions.#{parent.model_name.i18n_key}.#{state}")
  end

  def iri_opts
    {parent_iri: parent_iri_path, id: step}
  end

  def to_param
    step.to_s
  end

  private

  def correctly_forwarded # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
    if forwarded_group_id.nil? && forwarded_group.nil?
      errors.add(:forwarded_to, I18n.t('decisions.forward_group_missing'))
      return
    end
    return if forwarded_user_id.nil? && forwarded_user.nil?

    group_id = forwarded_group_id || forwarded_group.id
    user_id = forwarded_user.uuid || User.find(forwarded_user_id).uuid
    return if GroupMembership
                .joins(:member)
                .where(profiles: {profileable_type: 'User', profileable_id: user_id}, group_id: group_id)
                .any?

    errors.add(:forwarded_to, I18n.t('decisions.forward_failed', user_id: user_id, group_id: group_id))
  end

  class << self
    # @return [Array<Symbol>] States that indicate an action was taken on this decision
    def actioned_keys
      states.keys[1..]
    end
  end
end
