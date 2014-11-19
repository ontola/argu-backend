require 'spec_helper'

describe "motions/edit" do
  before(:each) do
    @motion = FactoryGirl.create :motion
    assign(:motion, @motion)
  end

  it "renders the edit motion form" do
    render template: 'motions/form'

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => motions_path(@motion), :method => "post" do
      assert_select "input#motion_title", :name => "motion[title]"
      assert_select "textarea#motion_content", :name => "motion[content]"
    end
  end
end
