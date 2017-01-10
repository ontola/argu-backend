# frozen_string_literal: true
class PageSerializer < RecordSerializer
  attributes :display_name, :about
  has_one :profile_photo do
    obj = object.profile.default_profile_photo
    link(:self) do
      {
        meta: {
          '@type': 'http://schema.org/image'
        }
      }
    end
    link(:related) do
      {
        href: obj.context_id,
        meta: {
          '@type': 'http://schema.org/ImageObject'
        }
      }
    end
    obj
  end

  def about
    object.profile.about
  end
end
