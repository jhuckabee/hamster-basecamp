require 'spec_helper'

describe TimeEntry do
  describe "#import!" do
    it "should import the time entry into the account" do
      time_entry = TimeEntry.new
      fact = mock_model(TimeEntry)
      time_entry.stub!(:fact).and_return(fact)
      activity = mock_model(Activity)
      fact.stub!(:activity).and_return(activity)
      category = mock_model(Category)
      activity.stub!(:category).and_return(category)
      account = mock_model(Account)
      category.stub!(:account).and_return(account)
      account.should_receive(:create_todo).and_return(true)
      time_entry.import!.should be_true
    end
  end
end
