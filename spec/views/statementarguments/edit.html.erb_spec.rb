require 'spec_helper'

describe "statementarguments/edit" do
  before(:each) do
    @statementargument = assign(:statementargument, stub_model(Statementargument,
      :pro => false
    ))
  end

  it "renders the edit statementargument form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => statementarguments_path(@statementargument), :method => "post" do
      assert_select "input#statementargument_pro", :name => "statementargument[pro]"
    end
  end
end
