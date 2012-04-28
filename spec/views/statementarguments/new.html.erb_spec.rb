require 'spec_helper'

describe "statementarguments/new" do
  before(:each) do
    assign(:statementargument, stub_model(Statementargument,
      :pro => false
    ).as_new_record)
  end

  it "renders new statementargument form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => statementarguments_path, :method => "post" do
      assert_select "input#statementargument_pro", :name => "statementargument[pro]"
    end
  end
end
