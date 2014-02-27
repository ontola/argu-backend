require 'spec_helper'

describe "statementarguments/index" do
  before(:each) do
    assign(:statementarguments, [
      stub_model(Statementargument,
        :pro => false
      ),
      stub_model(Statementargument,
        :pro => false
      )
    ])
  end

  it "renders a list of statementarguments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
