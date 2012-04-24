require 'spec_helper'

describe "statements/show" do
  before(:each) do
    @statement = assign(:statement, stub_model(Statement,
      :content => "Content",
      :pros => "",
      :cons => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Content/)
    rendered.should match(//)
    rendered.should match(//)
  end
end
