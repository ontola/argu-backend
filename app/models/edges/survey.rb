# frozen_string_literal: true

class Survey < Discussion
  TYPEFORM_MANAGE_TEMPLATE = URITemplate.new('https://admin.typeform.com/form/{typeform_id}/create')
  TYPEFORM_TEMPLATE = %r{\Ahttps://(\w*).typeform.com/to/(\w*)(\?__dangerous-disable-submissions)?\z}.freeze

  enhance CouponBatchable
  enhance Settingable

  include Edgeable::Content

  property :external_iri, :iri, NS.argu[:externalIRI]
  property :reward, :integer, NS.argu[:reward], default: 0
  property :action_body_id,
           :linked_edge_id,
           NS.argu[:actionBody],
           association_class: 'CustomForm'
  accepts_nested_attributes_for :action_body

  parentable :container_node, :page, :phase
  with_collection :submissions
  enum form_type: {local: 0, remote: 1}
  attr_writer :form_type

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :external_iri, format: {allow_nil: true, with: TYPEFORM_TEMPLATE}

  def added_delta
    super + [
      invalidate_resource_delta(menu(:tabs))
    ]
  end

  def currency
    'EUR'
  end

  def has_reward?
    reward.positive?
  end

  def form_type
    external_iri.present? ? :remote : :local
  end

  def manage_iri
    TYPEFORM_MANAGE_TEMPLATE.expand(typeform_id: typeform_id) if external_iri
  end

  def submission_for(user_context)
    return nil if user_context.nil?

    if user_context.guest?
      submissions.reorder(created_at: :desc).find_by(session_id: user_context.session_id)
    else
      submissions.reorder(created_at: :desc).find_by(publisher: user_context.user)
    end
  end

  def typeform_account
    typeform_tuple[1]
  end

  def typeform_id
    typeform_tuple[2]
  end

  private

  def typeform_tuple
    external_iri&.to_s&.match(Survey::TYPEFORM_TEMPLATE) || []
  end

  class << self
    def build_new(parent: nil, user_context: nil)
      resource = super
      resource.build_action_body(
        creator: user_context&.profile,
        display_name: I18n.t('argu.CustomForm.label'),
        parent: resource,
        publisher: user_context&.user
      )
      resource
    end
  end
end
