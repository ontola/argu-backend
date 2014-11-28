require 'spec_helper'

describe "motions/show" do
  before(:each) do
    @motion = FactoryGirl.create :motion
    pro = [FactoryGirl.create(:argument, motion: @motion, pro: true), FactoryGirl.create(:argument, motion: @motion, pro: true)]
    con = [FactoryGirl.create(:argument, motion: @motion, pro: false), FactoryGirl.create(:argument, motion: @motion, pro: false)]
    @arguments = {pro: pro, con: con}
    assign(:motion, @motion)
    assign(:arguments, @arguments)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Content/)
    rendered.should match(/Title/)
  end
end
