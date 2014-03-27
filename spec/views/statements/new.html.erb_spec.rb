require 'spec_helper'

describe "statements/new" do
  before(:each) do
    @statement = FactoryGirl.create :statement
    assign(:statement, @statement)
  end

  it "renders new statement form" do
    render template: 'statements/form'

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => statements_path, :method => "post" do
      assert_select "input#statement_title", :name => "statement[title]"
      assert_select "textarea#statement_content", :name => "statement[content]"
    end
  end
end
