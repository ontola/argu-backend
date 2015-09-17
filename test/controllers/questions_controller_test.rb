require 'test_helper'

class QuestionsControllerTest < Argu::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum,
                                      name: 'holland') }
  let(:subject) { FactoryGirl.create(:question,
                                     :with_motions) }

  ####################################
  # As Guest
  ####################################
  test 'should get show when not logged in', tenant: :holland do
    get :show, id: subject.id
    assert_response 200
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:motions)

    assert subject.motions.where(is_trashed: true).count > 0, 'No trashed motions to test visibility on'
    assert_not assigns(:motions).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should get show', tenant: :holland do
    sign_in user

    get :show, id: subject.id
    assert_response 200
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:motions)

    assert_not assigns(:motions).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  ####################################
  # As Member
  ####################################
  let(:member) { make_member(holland) }

  test 'should post create', tenant: :holland do
    sign_in member

    assert_difference('Question.count') do
      post :create,
           question: {
               title: 'Question',
               content: 'Contents'}
    end
    assert_not_nil assigns(:question)
    assert_redirected_to question_url(assigns(:question))
  end

  test 'should not put update on others question', tenant: :holland do
    sign_in member

    put :update,
        id: subject,
        question: {
            title: 'New title',
            content: 'new contents'}

    assert_equal subject, assigns(:question)
  end


  test 'should not get convert', tenant: :holland do
    sign_in member

    get :convert, question_id: subject
    assert_redirected_to root_url
  end

  test 'should not put convert', tenant: :holland do
    sign_in member

    put :convert, question_id: subject
    assert_redirected_to root_url
  end

  test 'should not get move', tenant: :holland do
    sign_in member

    get :move, question_id: subject
    assert_redirected_to root_url
  end

  test 'should not put move', tenant: :holland do
    sign_in member

    put :move, question_id: subject
    assert_redirected_to root_url
  end


  ####################################
  # As Creator
  ####################################
  let(:creator) { make_member(holland) }
  let(:creator_question) { FactoryGirl.create(:question,
                                            tenant: :holland,
                                            creator: creator.profile) }

  test 'should put update on own question', tenant: :holland do
    sign_in creator

    put :update,
        id: creator_question,
        question: {
            title: 'New title',
            content: 'new contents'}

    assert_not_nil assigns(:question)
    assert_equal 'New title', assigns(:question).title
    assert_equal 'new contents', assigns(:question).content
    assert_redirected_to question_url(creator_question)
  end

  ####################################
  # For Page owners
  ####################################
  let(:page_owner) { FactoryGirl.create(:user) }
  let(:page) { FactoryGirl.create(:page, owner: page_owner.profile) }
  let(:page_question) { FactoryGirl.create(:question,
                                              tenant: :holland,
                                              creator: page.profile) }

  test 'should put update on page owner own question', tenant: :holland do
    sign_in page_owner
    set_current_profile page.profile

    put :update,
        id: page_question,
        question: {
            title: 'New title',
            content: 'new contents'}

    assert_redirected_to question_url(assigns(:question))
    assert_not_nil assigns(:question)
    assert_equal 'New title', assigns(:question).title
    assert_equal 'new contents', assigns(:question).content
  end

  ####################################
  # For Staff
  ####################################
  let(:staff) { FactoryGirl.create(:user, :staff) }

  # Currently only staffers can convert items
  test 'should get convert', tenant: :holland do
    sign_in staff

    get :convert, question_id: subject
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'should put convert', tenant: :holland do
    sign_in staff

    put :convert!, question_id: subject, question: {f_convert: 'motions'}
    assert assigns(:result)
    assert_redirected_to assigns(:result)[:new]

    assert_equal Motion, assigns(:result)[:new].class
    assert assigns(:result)[:old].destroyed?

    # Test direct relations
    assert_equal 0, assigns(:result)[:old].taggings.count
    assert_equal 1, assigns(:result)[:new].taggings.count

    assert_equal 0, assigns(:result)[:old].votes.count
    assert_equal 1, assigns(:result)[:new].votes.count

    assert_equal 0, assigns(:result)[:old].activities.count
    assert_equal 1, assigns(:result)[:new].activities.count

  end

end
