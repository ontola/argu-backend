module MailerHelper
  include AlternativeNamesHelper, ProfilesHelper

  def link_to_creator(object)
    link_to object.creator.display_name,
            dual_profile_url(object.creator),
            title: object.display_name
  end

  def link_to_object(object, description = nil)
    link_to(description || type_for(object),
            object,
            title: object.display_name)
  end

end
