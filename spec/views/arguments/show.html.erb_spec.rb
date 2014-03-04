require 'spec_helper'

describe "arguments/show" do
  before(:each) do
    @user = FactoryGirl.create :user
    sign_in @user
    #sign_in FactoryGirl.create :user
    #@argument = FactoryGirl.create :argument
    #@comments = []
    #assign(:argument, @argument)
    #assign(:comments, @comments)
  end

  it "renders attributes in <p>", :versioning => true  do
    PaperTrail.whodunnit = @user
    @argument = FactoryGirl.create :argument
    @comments = []
    assign(:argument, @argument)
    assign(:comments, Kaminari.paginate_array(@comments).page(1))
    render

    assert_select ".box>h1.title", :text => @argument.title
    assert_select ".box>p.intro", :text => @argument.content
  end
end
