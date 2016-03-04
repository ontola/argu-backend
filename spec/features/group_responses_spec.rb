require 'rails_helper'

RSpec.feature 'Login', type: :feature do

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
  let!(:holland_member) { create_member(holland) }
  let(:user) { FactoryGirl.create(:user_with_votes) }


  ####################################
  # As Group Member
  ####################################
  scenario 'group member creates a group response' do

  end

  ####################################
  # As Page
  ####################################
  scenario 'page creates a group response' do

  end


end
