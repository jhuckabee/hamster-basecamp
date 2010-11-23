require 'spec_helper'

describe Fact do
  describe "#minutes" do
    before do
      @fact = Fact.new
    end

    it "should return 0 if the start_time is blank" do
      @fact.minutes.should == 0
    end
    
    it "should return 0 if the end_time is blank" do
      @fact.start_time = 5.minutes.ago
      @fact.minutes.should == 0
    end

    it "should return number of minutes between start and end time" do
      @fact.start_time = 10.minutes.ago
      @fact.end_time = 5.minutes.ago
      @fact.minutes.to_i.should == 5
    end
  end

  describe "#hours" do
    before do
      @fact = Fact.new
    end

    it "should return 0 if minutes is 0" do
      @fact.stub!(:minutes).and_return(0)
      @fact.hours.should == 0
    end

    it "should return the number of hours in decimal format based on the number of minutes passed" do
      @fact.stub!(:minutes).and_return(60.0)
      @fact.hours.should == 1.0
    end
  end

  describe "#time_entry_id" do
    before do
      @fact = Fact.new
    end

    it "should return nil if the corresponding time entry is blank" do
      @fact.stub!(:time_entry).and_return(nil)
      @fact.time_entry_id.should be_nil
    end

    it "should return the id for the corresponding time entry if the time entry is not blank" do
      @fact.stub!(:time_entry).and_return(mock_model(TimeEntry, :time_entry_id => 1))
      @fact.time_entry_id.should == 1
    end
  end

  describe "#todo_id" do
    before do
      @fact = Fact.new
    end
    
    it "should return nil if the corresponding time entry is blank" do
      @fact.stub!(:time_entry).and_return(nil)
      @fact.todo_id.should be_nil
    end

    it "should return the todo id for the corresponding time entry if the time entry is not blank" do
      @fact.stub!(:time_entry).and_return(mock_model(TimeEntry, :todo_id => 1))
      @fact.todo_id.should == 1
    end
  end

  describe "#ignore!" do
    before do
      @fact = Fact.new
    end

    it "should create a time entry with time entry and todo ids set to 0" do
      @fact.should_receive(:build_time_entry).and_return(mock_model(TimeEntry, :save => true))
      @fact.ignore!
    end

    it "should return nothing if a time entry already exists" do
      @fact.stub!(:time_entry).and_return(mock_model(TimeEntry))
      @fact.ignore!.should be_false
    end
  end

  describe "#import" do
    before do
      @fact = Fact.new
    end

    it "should create a time entry with corresponding time entry and todo ids and import it" do
      time_entry = mock_model(TimeEntry, :save => true)
      @fact.should_receive(:build_time_entry).and_return(time_entry)
      time_entry.should_receive(:'import!')
      @fact.import!
    end

    it "should raise an error if a time entry already exists" do
      @fact.stub!(:time_entry).and_return(mock_model(TimeEntry))
      @fact.import!.should be_false
    end
  end
end
