require 'spec_helper'

describe "arguments/show" do
  before(:each) do
    @argument = assign(:argument, stub_model(Argument,
      :title => "Title",
      :content => "Content",
      :type => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/Content/)
    rendered.should match(/1/)
  end
end
