require 'rails_helper'

RSpec.feature 'Signup', type: :feature do
  let!(:default_forum) { create(:setting, key: 'default_forum', value: 'default') }
  let!(:default) { create(:forum, name: 'default') }
  let!(:freetown) { create(:forum, name: 'freetown') }
  let!(:motion) { create(:motion, forum: freetown) }

  scenario 'should register w/ oauth and preserve vote on non-default forum' do
    OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new(
        {
          provider: 'facebook',
          uid: '111907595807605',
          credentials: {
            token: 'CAAKvnjt9N54BACAJ6Uj5LFywuhmo5vy2VUyvBqtZAPrZAUH10sy4KgxZAU0mZConMqV9ZB6kO4eZCC3Y822NbZCXdBjZAjUE9ubUscZBZB5WGHn32jIn2NU7UZAVYbAYWcmfg0vutOLZAw3LDs8YE2O5k2Nwde7zzMK1hyBrZC30wvIFnbjoaGegXEZBbL1fyJjGTUBLADCOczzZAHkDhH3mYqJp2y2'
          },
          info: {
            email: 'testuser@example.com',
            first_name: 'First',
            last_name: 'Last'
          },
          extra: {
            raw_info: {
              middle_name: 'Middle'
            }
          }
        })

    visit root_path
    expect(page).to have_content 'default'
    expect(current_path).to eq forum_path(default)

    visit forum_path(freetown)
    expect(page).to have_content 'freetown'

    click_link motion.title
    expect(page).to have_content(motion.content)

    click_link 'Neither'
    expect(page).to have_content 'Sign up'

    click_link 'Log in with Facebook'

    expect(current_path).to eq setup_users_path
    click_button 'Volgende'

    click_button 'Geen van beide'

    expect(page).to have_content motion.title
    expect(page).to have_css 'a.btn-neutral[data-voted-on=true]'
  end

end
