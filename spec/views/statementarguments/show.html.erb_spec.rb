require 'spec_helper'

describe "statementarguments/show" do
  before(:each) do
    @statementargument = assign(:statementargument, stub_model(Statementargument,
      :pro => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
  end
end
