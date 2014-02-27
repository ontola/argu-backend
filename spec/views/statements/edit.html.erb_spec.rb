require 'spec_helper'

describe "statements/edit" do
  before(:each) do
    @statement = assign(:statement, stub_model(Statement,
      :content => "MyString",
      :pros => "",
      :cons => ""
    ))
  end

  it "renders the edit statement form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => statements_path(@statement), :method => "post" do
      assert_select "input#statement_content", :name => "statement[content]"
      assert_select "input#statement_pros", :name => "statement[pros]"
      assert_select "input#statement_cons", :name => "statement[cons]"
    end
  end
end
