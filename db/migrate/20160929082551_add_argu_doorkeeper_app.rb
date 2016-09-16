class AddArguDoorkeeperApp < ActiveRecord::Migration[5.0]
  def change
    if Doorkeeper::Application.find_by(id: 0).blank?
      Doorkeeper::Application.create!(
        id: 0,
        name: 'Argu',
        owner: Profile.find(0),
        redirect_uri: 'https://argu.co/'
      )
    end
  end
end
