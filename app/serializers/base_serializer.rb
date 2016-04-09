class BaseSerializer < ActiveModel::Serializer
  def tenant
    object.forum.url if object.respond_to? :forum
  end
  # alias_method :forum, :tenant
end
