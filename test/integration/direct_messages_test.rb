# frozen_string_literal: true

require 'test_helper'

class DirectMessagesTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }

  ####################################
  # As Guest
  ####################################
  test 'guest should not post create direct_message' do
    sign_in :guest_user

    post collection_iri(argu, :direct_messages),
         params: {direct_message: valid_params}
    assert_not_a_user
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not post create direct_message' do
    sign_in user
    post collection_iri(argu, :direct_messages),
         params: {direct_message: valid_params, actor_iri: resource_iri(administrator, root: argu)}
    assert_not_authorized
  end

  ####################################
  # As Administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }
  let(:unconfirmed_email) { create(:email_address, user: administrator, email: 'unconfirmed@argu.co') }

  test 'administrator should post create direct_message' do
    create_email_mock(
      'direct_message',
      motion.publisher.email,
      actor: {
        display_name: administrator.display_name,
        iri: resource_iri(administrator, root: argu),
        thumbnail: administrator.profile.default_profile_photo.thumbnail
      },
      body: 'body',
      email: administrator.email,
      resource: {iri: motion.iri, display_name: motion.display_name},
      subject: 'subject'
    )

    sign_in administrator
    post collection_iri(argu, :direct_messages),
         params: {direct_message: valid_params, actor_iri: resource_iri(administrator, root: argu)}
    assert_response :created
    assert_email_sent(skip_sidekiq: true)
  end

  test 'administrator should not post create direct_message with unconfirmed e-mail' do
    sign_in administrator
    post collection_iri(argu, :direct_messages),
         params: {
           direct_message: valid_params.merge(email_address_id: unconfirmed_email.iri),
           actor_iri: resource_iri(administrator, root: argu)
         }
    assert_not_authorized
  end

  test 'administrator should not post create direct_message with other email' do
    sign_in administrator
    post collection_iri(argu, :direct_messages),
         params: {
           direct_message: valid_params.merge(email_address_id: user.primary_email_record.iri),
           actor_iri: resource_iri(administrator, root: argu)
         }
    assert_not_authorized
  end

  test 'administrator should not post create direct_message with missing body' do
    sign_in administrator

    post collection_iri(argu, :direct_messages),
         params: {direct_message: valid_params.except(:body), actor_iri: resource_iri(administrator, root: argu)}
    assert_response :unprocessable_entity
  end

  test 'administrator should not post create direct_message with missing subject' do
    sign_in administrator
    post collection_iri(argu, :direct_messages),
         params: {direct_message: valid_params.except(:subject), actor_iri: resource_iri(administrator, root: argu)}
    assert_response :unprocessable_entity
  end

  test 'administrator should not post create direct_message with unpermitted actor' do
    sign_in administrator
    post collection_iri(argu, :direct_messages),
         params: {direct_message: valid_params, actor_iri: resource_iri(user, root: argu)}
    assert_not_authorized
  end

  private

  def valid_params
    {
      body: 'body',
      email_address_id: administrator.primary_email_record.iri,
      subject: 'subject',
      resource_iri: motion.iri
    }
  end
end
