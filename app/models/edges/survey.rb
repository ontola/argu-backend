# frozen_string_literal: true

class Survey < Discussion
  TYPEFORM_MANAGE_TEMPLATE = URITemplate.new('https://admin.typeform.com/form/{typeform_id}/create')
  TYPEFORM_TEMPLATE = %r{\Ahttps://(\w*).typeform.com/to/(\w*)(\?__dangerous-disable-submissions)?\z}.freeze

  enhance CouponBatchable
  enhance Settingable

  include Edgeable::Content

  property :external_iri, :iri, NS.argu[:externalIRI]
  property :action_body, :iri, NS.ll[:actionBody]
  property :reward, :integer, NS.argu[:reward], default: 0
  parentable :container_node, :page, :phase
  with_collection :submissions
  enum form_type: {remote: 0, local: 1}
  attr_writer :form_type

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :external_iri, format: {allow_nil: true, with: TYPEFORM_TEMPLATE}

  def added_delta
    super + [
      invalidate_resource_delta(menu(:settings))
    ]
  end

  def currency
    'EUR'
  end

  def has_reward?
    reward.positive?
  end

  def form_type
    action_body.present? ? :local : :remote
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
end
