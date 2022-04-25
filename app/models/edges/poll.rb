# frozen_string_literal: true

class Poll < Discussion
  enhance ActivePublishable
  enhance Votable

  include Edgeable::Content

  validates :description, presence: false, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 75}
  validates :options_vocab, presence: true

  parentable :container_node, :phase
  property :options_vocab_id,
           :linked_edge_id,
           NS.argu[:optionsVocab],
           association_class: 'Vocabulary'
  accepts_nested_attributes_for :options_vocab

  class << self
    def build_new(parent: nil, user_context: nil)
      resource = super
      resource.build_options_vocab(
        creator: user_context&.profile,
        display_name: I18n.t('forms.default.options_vocab_id.label'),
        publisher: user_context&.user
      )
      resource
    end
  end
end
