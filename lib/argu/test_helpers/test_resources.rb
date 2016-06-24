# frozen_string_literal: true

module TestResources
  module InstanceMethods
    def create_forum(*args)
      attributes = (args.pop if args.last.is_a?(Hash)) || {}
      page = attributes.delete(:page) || create(:page)
      attributes = {
        shortname_attributes: attributes_for(:shortname),
        parent: page.edge,
        page: page,
        options: {
          publisher: page.owner.profileable
        }
      }.merge(attributes)
      create(
        :forum,
        *args,
        attributes)
    end
  end

  module ClassMethods
    def define_page
      let!(:argu) { create(:page) }
    end

    def define_freetown(name = 'freetown', attributes: {})
      define_page
      let!(name) do
        create_forum(
          :with_follower,
          {
            shortname_attributes: {shortname: name},
            page: argu,
            parent: argu.edge
          }.merge(attributes)
        )
      end
    end

    def define_cairo(name = 'cairo')
      let(name) do
        create_forum(
          shortname_attributes: {shortname: name},
          visibility: Forum.visibilities[:closed])
      end
    end
  end
end
