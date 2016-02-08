class BaseSerializer < ActiveModel::Serializer

  def tenant
    if object.respond_to? :forum
      object.forum.url
    end
  end
  #alias_method :forum, :tenant
end
