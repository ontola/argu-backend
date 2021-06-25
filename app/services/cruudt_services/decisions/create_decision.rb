# frozen_string_literal: true

class CreateDecision < CreateEdge
  def initialize(parent, attributes: {}, options: {})
    if attributes['forwarded_user_id']
      attributes[:forwarded_user] = User.find_by(id: attributes.delete('forwarded_user_id'))
    end
    super
  end

  private

  def after_save
    notify
  end

  def prepare_argu_publication_attributes
    super
    return if @attributes['state'] == 'forwarded'

    @attributes[:argu_publication_attributes][:follow_type] = 'news'
  end
end
