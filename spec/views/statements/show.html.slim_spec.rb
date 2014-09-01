require 'spec_helper'

describe "statements/show" do
  before(:each) do
    @statement = FactoryGirl.create :statement
    pro = [FactoryGirl.create(:argument, statement: @statement, pro: true), FactoryGirl.create(:argument, statement: @statement, pro: true)]
    con = [FactoryGirl.create(:argument, statement: @statement, pro: false), FactoryGirl.create(:argument, statement: @statement, pro: false)]
    @arguments = {pro: pro, con: con}
    assign(:statement, @statement)
    assign(:arguments, @arguments)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Content/)
    rendered.should match(/Title/)
  end
end
