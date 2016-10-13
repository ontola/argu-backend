# frozen_string_literal: true
require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let!(:subject) do
    p = create(:project,
               argu_publication: build(:publication),
               publisher: creator,
               parent: freetown.edge)
    create(:stepup,
           record: p,
           forum: freetown,
           moderator: moderator)
    p
  end
  let(:unpublished) do
    p = create(:project, publisher: creator, parent: freetown.edge)
    create(:stepup,
           record: p,
           forum: freetown,
           moderator: moderator)
    p
  end

  define_tests do
    hash = {}
    define_test(hash, :new, options: {parent: :freetown}, user_types: user_types[:new].merge(
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']}
    ))
    define_test(hash, :show)
    define_test(
      hash,
      :show,
      case_suffix: ' unpublished',
      options: {record: :unpublished},
      user_types: user_types[:show].merge(
        guest: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
        user: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
        member: {rshould: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']}
      )
    )
    define_test(hash, :show, case_suffix: ' non-existent', options: {record: -1}, user_types: {
                  user: {should: false, response: 404}
                })
    define_test(
      hash,
      :create,
      case_suffix: ' draft',
      options: {
        parent: :freetown,
        analytics: stats_opt('projects', 'create_success'),
        attributes: {
          happened_at: DateTime.current,
          argu_publication_attributes: {publish_type: :draft}
        },
        differences: [['Project.unpublished', 1],
                      ['Activity.loggings', 1],
                      ['Notification', 0]]
      },
      user_types: {
        guest: {
          should: false,
          analytics: false,
          response: 302,
          asserts: ['assigns(:_not_a_user_caught)']
        },
        user: {
          should: false,
          analytics: false,
          response: 403,
          asserts: ['assigns(:_not_a_member_caught)']
        },
        member: {
          should: false,
          analytics: false,
          response: 302,
          asserts: ['assigns(:_not_authorized_caught)']
        },
        moderator: {
          should: true,
          response: 302,
          asserts: ['moderator.reload.has_drafts?', '!Project.last.is_published?']
        },
        manager: {
          should: true,
          response: 302,
          asserts: ['manager.reload.has_drafts?', '!Project.last.is_published?']
        },
        owner: {
          should: true,
          response: 302,
          asserts: ['owner.reload.has_drafts?', '!Project.last.is_published?']
        },
        staff: {
          should: true,
          response: 302,
          asserts: ['staff.reload.has_drafts?', '!Project.last.is_published?']
        }
      }
    )
    define_test(
      hash,
      :create,
      case_suffix: ' published',
      options: {
        parent: :freetown,
        analytics: stats_opt('projects', 'create_success'),
        attributes: {
          happened_at: DateTime.current,
          argu_publication_attributes: {publish_type: :direct}
        },
        differences: [['Project.published', 1],
                      ['Activity.loggings', 2],
                      ['Notification', 1]]
      },
      user_types: {
        moderator: {
          should: true,
          response: 302,
          asserts: ['!moderator.reload.has_drafts?', 'Project.last.is_published?']
        },
        manager: {
          should: true,
          response: 302,
          asserts: ['!moderator.reload.has_drafts?', 'Project.last.is_published?']
        },
        owner: {
          should: true,
          response: 302,
          asserts: ['!moderator.reload.has_drafts?', 'Project.last.is_published?']
        },
        staff: {
          should: true,
          response: 302,
          asserts: ['!moderator.reload.has_drafts?', 'Project.last.is_published?']
        }
      }
    )
    define_test(
      hash,
      :create,
      case_suffix: ' erroneous',
      options: {
        parent: :freetown,
        analytics: stats_opt('projects', 'create_failed'),
        attributes: {title: 'Project', content: 'C'}
      },
      user_types: {
        manager: {
          should: false,
          response: 200,
          asserts: ['assert_select "#project_title", "Project"',
                    'assert_select "#project_content", "C"']
        }
      }
    )
    define_test(
      hash,
      :create,
      case_suffix: ' with cover_photo',
      options: {
        parent: :freetown,
        analytics: stats_opt('projects', 'create_success'),
        attributes: {
          default_cover_photo_attributes: {
            image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
          }
        }
      },
      user_types: {
        manager: {
          should: true,
          response: 302,
          asserts: ['assert_equal "cover_photo.jpg", resource.default_cover_photo.image_identifier',
                    'assert_equal 1, resource.photos.count']
        }
      }
    )
    define_test(hash, :edit, user_types: user_types[:edit]
                                           .except(:creator)
                                           .merge(moderator: {should: true, response: 200}))
    define_test(hash, :update, user_types: user_types[:update]
                                             .except(:creator)
                                             .merge(moderator: {should: true, response: 302}))
    define_test(
      hash,
      :update,
      case_suffix: ' erroneous',
      options: {attributes: {title: 'Project', content: 'C'}},
      user_types: {
        manager: {
          should: false,
          response: 200,
          asserts: ['assert_select "#project_title", "Project"',
                    'assert_select "#project_content", "C"']
        }
      }
    )
    define_test(
      hash,
      :update,
      case_suffix: ' with cover_photo',
      options: {
        attributes: {
          default_cover_photo_attributes: {
            image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
          }
        }
      },
      user_types: {
        manager: {
          should: true,
          response: 302,
          asserts: ['assert_equal "cover_photo.jpg", resource.default_cover_photo.image_identifier',
                    'assert_equal 1, resource.photos.count']
        }
      }
    )
    define_test(hash, :destroy, options: {analytics: stats_opt('projects', 'destroy_success')})
    define_test(hash,
                :trash,
                options: {analytics: stats_opt('projects', 'trash_success')},
                user_types: user_types[:trash]
                              .merge(moderator: {should: true, response: 302}))
  end

  ####################################
  # As NetDem member
  # The following tests are specific to the use case of NetDem
  ####################################
  let(:netdem) { create(:group, name: 'Netwerk Democratie', parent: freetown.page.edge) }
  let(:netdem_member) { create_member(freetown) }
  let(:netdem_membership) do
    create(:group_membership,
           member: netdem_member.profile,
           parent: netdem.edge)
  end
  let(:netdem_rule_new) do
    create(:rule,
           branch: freetown.edge,
           model_type: 'Project',
           action: 'new?',
           role: netdem.identifier,
           permit: true)
  end
  let(:netdem_rule_create) do
    create(:rule,
           branch: freetown.edge,
           model_type: 'Project',
           action: 'create?',
           role: netdem.identifier,
           permit: true)
  end
  let(:discussion_group) { create(:group, name: 'Politieke Partijen', parent: freetown.page.edge) }
  let(:discussion_member) { create_member(freetown) }
  let(:discussion_membership) do
    create(:group_membership,
           member: discussion_member.profile,
           parent: discussion_group.edge)
  end
  def netdem_rules
    [netdem_membership, discussion_membership, netdem_rule_new, netdem_rule_create]
  end

  test 'moderator should get new project' do
    netdem_rules
    sign_in netdem_member

    general_new(results: {response: 200}, parent: :freetown)
  end

  test 'moderator should post create project draft' do
    netdem_rules
    sign_in netdem_member
    moderator.shortname.update(shortname: 'moderator_name')
    # Test post create
    # Test that the proper stepup is generated
    general_create(results: {response: 302, should: true},
                   parent: :freetown,
                   analytics: stats_opt('projects', 'create_success'),
                   attributes: attributes_for(
                     :project,
                     argu_publication_attributes: {publish_type: :draft},
                     stepups_attributes: {'12321' => {moderator: 'moderator_name'}},
                     phases_attributes: {'12321' => attributes_for(:phase)}
                   ),
                   differences: [['Project', 1],
                                 ['Project.published', 0],
                                 ['Stepup', 1],
                                 ['Phase', 1]])
  end

  test 'moderator should post create project publish' do
    netdem_rules
    sign_in netdem_member
    moderator.shortname.update(shortname: 'moderator_name')
    # Test post create
    # Test that the proper stepup is generated
    general_create(results: {response: 302, should: true},
                   parent: :freetown,
                   analytics: stats_opt('projects', 'create_success'),
                   attributes: attributes_for(
                     :project,
                     argu_publication_attributes: {publish_type: :direct},
                     stepups_attributes: {'12321' => {moderator: 'moderator_name'}},
                     phases_attributes: {'12321' => attributes_for(:phase)}
                   ),
                   differences: [['Project', 1],
                                 ['Project.published', 1],
                                 ['Stepup', 1],
                                 ['Phase', 1]])
  end

  test 'moderator should not cause leaking access' do
    netdem_rules
    sign_in discussion_member

    moderator.shortname.update(shortname: 'moderator_name')
    general_new(results: {response: 302}, parent: :freetown)
    general_create(results: {response: 302, should: false},
                   parent: :freetown,
                   attributes: attributes_for(
                     :project,
                     argu_publication_attributes: {publish_type: :draft},
                     stepups_attributes: {'12321' => {moderator: 'moderator_name'}},
                     phases_attributes: {'12321' => attributes_for(:phase)}
                   ),
                   differences: [['Project', 0],
                                 ['Stepup', 0],
                                 ['Phase', 0]])
  end
end
