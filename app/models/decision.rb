# frozen_string_literal: true

class Decision < Edge
  include Loggable
  include Happenable
  include HasLinks
  include ActivePublishable
  include Menuable

  belongs_to :creator, class_name: 'Profile'
  belongs_to :forum
  belongs_to :forwarded_group, class_name: 'Group'
  belongs_to :forwarded_user, class_name: 'User'
  belongs_to :publisher, inverse_of: :decisions, class_name: 'User'
  has_one :decision_activity,
          -> { where("key ~ '*.?'", Decision.actioned_keys.join('|').freeze) },
          foreign_key: :trackable_edge_id,
          class_name: 'Activity',
          inverse_of: :trackable,
          primary_key: :uuid

  enum state: {pending: 0, approved: 1, rejected: 2, forwarded: 3}
  validates :happening, presence: true, unless: :pending?
  validate :correctly_forwarded, if: :forwarded?
  alias_attribute :title, :display_name
  alias_attribute :description, :content
  parentable :motion

  # @return [Array<Symbol>] States that indicate an action was taken on this decision
  def self.actioned_keys
    states.keys[1..-1]
  end

  def display_name
    I18n.t("decisions.#{parent_model.model_name.i18n_key}.#{state}")
  end

  def iri_opts
    {parent_iri: parent_iri(only_path: true), id: step}
  end

  def to_param
    step.to_s
  end

  private

  def correctly_forwarded
    if forwarded_group.nil? ||
        (forwarded_user.present? &&
          GroupMembership.where(member: forwarded_user.profile, group: forwarded_group).empty?)
      errors.add(:forwarded_to, I18n.t('decisions.forward_failed'))
    end
  end
end
