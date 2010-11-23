require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the AccountsHelper. For example:
#
# describe AccountsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ApplicationHelper do
  describe "formatted_number" do
    it "should return a number in string format with 2 decimal places" do
      helper.formatted_number(0).should == '0.00'
      helper.formatted_number(1).should == '1.00'
      helper.formatted_number(1.1).should == '1.10'
      helper.formatted_number(0.1).should == '0.10'
    end
  end
end
