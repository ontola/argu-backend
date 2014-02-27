require 'spec_helper'

describe "statements/index" do
  before(:each) do
    assign(:statements, [
      stub_model(Statement,
        :content => "Content",
        :pros => "",
        :cons => ""
      ),
      stub_model(Statement,
        :content => "Content",
        :pros => "",
        :cons => ""
      )
    ])
  end

  it "renders a list of statements" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Content".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
