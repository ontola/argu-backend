class ArguFrontEndApplication < ActiveRecord::Migration[5.1]
  def up
    afe = Doorkeeper::Application
            .find_or_create_by(id: Doorkeeper::Application::AFE_ID)
    afe.update!(
        name: 'Argu Front End',
        owner: Profile.find(Profile::COMMUNITY_ID),
        redirect_uri: 'https://argu.co/'
      )
    afe.access_tokens.create!(resource_owner_id: User::COMMUNITY_ID, scopes: 'service afe')
  end
end
