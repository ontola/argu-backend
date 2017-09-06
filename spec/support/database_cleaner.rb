# frozen_string_literal: true

RSpec.configure do |config|
  if ENV['RSPEC_TRANSACTION']
    config.before(:suite) do
      DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])

      DatabaseCleaner.strategy = :transaction

      extend FactoryGirl::Syntax::Methods
      extend Argu::TestHelpers::TestHelperMethods::InstanceMethods

      create(:user,
             id: User::COMMUNITY_ID,
             shortname: build(:shortname, shortname: 'community'),
             email: 'community@argu.co',
             password: 'password',
             first_name: nil,
             last_name: nil,
             profile: build(:profile, id: Profile::COMMUNITY_ID))
      create(:page,
             id: 0,
             last_accepted: DateTime.current,
             profile: Profile.new(name: 'public page profile'),
             owner: User.create!(
               shortname: Shortname.new(shortname: 'page_owner'),
               profile: Profile.new,
               email: 'page_owner@argu.co'
             ).profile,
             shortname: Shortname.new(shortname: 'public_page'))
      public_membership =
        CreateGroupMembership.new(
          create(:group, id: Group::PUBLIC_ID, parent: Page.find(0).edge, name: 'Public group', name_singular: 'User'),
          attributes: {member: Profile.community},
          options: {publisher: User.community, creator: Profile.community}
        ).resource
      public_membership.save(validate: false)
      create(:group, id: Group::STAFF_ID, parent: Page.find(0).edge, name: 'Staff group', name_singular: 'Staff')
      Doorkeeper::Application.create!(
        id: Doorkeeper::Application::ARGU_ID,
        name: 'Argu',
        owner: Profile.community,
        redirect_uri: 'http://example.com/'
      )

      page = create(:page, shortname_attributes: {shortname: 'argu'})
      freetown = create_forum(
        :with_follower,
        shortname_attributes: {shortname: 'freetown'},
        page: page,
        parent: page.edge,
        public_grant: 'member'
      )
      create_forum(
        :populated_forum,
        page: page,
        parent: page.edge,
        shortname_attributes: {shortname: 'holland'},
        discoverable: false,
        public_grant: 'none'
      )
      public_source = create(
        :source,
        parent: page.edge,
        iri_base: 'https://iri.test',
        public_grant: 'member',
        shortname: 'public_source'
      )
      linked_record = create(:linked_record, source: public_source)
      create(:argument, parent: linked_record.edge)
      linked_record_vote_event = linked_record.default_vote_event
      create(:vote, parent: linked_record_vote_event.edge)
      create(:project, parent: freetown.edge)
      forum_motion = create(:motion, parent: freetown.edge)
      create(:argument, parent: forum_motion.edge)
      question = create(:question, parent: freetown.edge)
      motion = create(:motion, parent: question.edge)
      actor_membership = create(:group_membership, parent: create(:group, parent: freetown.page.edge))
      create(:decision,
             parent: motion.edge,
             state: 'forwarded',
             forwarded_user: actor_membership.member.profileable,
             forwarded_group: actor_membership.group,
             happening_attributes: {happened_at: DateTime.current})
      vote_event = motion.default_vote_event
      create(:vote, parent: vote_event.edge)
      argument = create(:argument, parent: motion.edge)
      create(:vote, parent: argument.edge)
      comment = create(:comment, parent: argument.edge)
      create(:comment, parent: argument.edge, parent_id: comment.id)
      create(:blog_post, parent: motion.edge, happening_attributes: {happened_at: DateTime.current})
      blog_post = create(:blog_post, parent: question.edge, happening_attributes: {happened_at: DateTime.current})
      create(:comment, parent: blog_post.edge)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.after(:suite) do
      DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
    end
  else
    config.before(:suite) do
      DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
      DatabaseCleaner.strategy = :deletion
    end

    config.around(:each) do |example|
      if example.metadata[:clean_db_strategy]
        DatabaseCleaner.strategy = example.metadata[:clean_db_strategy]
      end

      DatabaseCleaner.cleaning do
        if example.metadata[:js] || example.metadata[:driver]
          ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
          example.run
          ActiveRecord::Base.shared_connection = nil
        else
          example.run
        end
      end

      DatabaseCleaner.strategy = :deletion if example.metadata[:clean_db_strategy]
    end
  end
end
