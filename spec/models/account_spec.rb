require 'spec_helper'

describe Account do
  describe '#establish_connection!' do
    before do
      @account = Account.new(:app_path => "http://test.example.com",
                             :username => "testuser",
                             :password => "password")
    end

    it "should return false if app_path is blank" do
      @account.app_path = nil
      @account.establish_connection!.should be_nil
    end

    it "should return false if the username is blank" do
      @account.username = nil
      @account.establish_connection!.should be_nil
    end

    it "should return false if the password is blank" do
      @account.password = nil
      @account.establish_connection!.should be_nil
    end

    it "should establish a basecamp connection if not already connected" do
      Basecamp.should_receive(:'establish_connection!')
      @account.establish_connection!
    end

    it "should not attempt to establish a connection if its already connected" do
      Basecamp.should_receive(:'establish_connection!').once
      @account.establish_connection!
      @account.establish_connection!
    end
  end

  describe '#basecamp' do
    before do
      @account = Account.new(:app_path => "http://test.example.com",
                             :username => "testuser",
                             :password => "password")
    end

    it "should return false if a connection can not be established" do
      @account.should_receive(:'establish_connection!').and_return(false)
      @account.basecamp.should be_nil
    end

    it "should attempt to establish a basecamp connection if not connected" do
      @account.should_receive(:'establish_connection!').and_return(true)
      @account.basecamp.should_not be_nil
    end

    it "should not attempt to establish a basecamp connection if a connection is already established" do
      Basecamp.should_receive(:'establish_connection!').once
      @account.establish_connection!
      @account.basecamp.should_not be_nil
    end
  end

  describe '#basecamp_connection' do
    before do
      @account = Account.new(:app_path => "http://test.example.com",
                             :username => "testuser",
                             :password => "password")
    end
    
    it "should return a basecamp connection" do
      connection = mock('Connection')
      Basecamp.should_receive(:connection).and_return(connection)
      @account.should_receive(:'establish_connection!').and_return(true)
      @account.basecamp_connection.should == connection
    end

    it "should return nil if unalbe to establish a basecamp connection" do
      @account.should_receive(:'establish_connection!').and_return(nil)
      @account.basecamp_connection.should be_nil
    end
  end

  describe '#companies' do
    before do
      @account = Account.new(:app_path => "http://test.example.com",
                             :username => "testuser",
                             :password => "password")
    end

    it "should return an empty array if basecamp doesn't exist" do
      @account.should_receive(:basecamp).and_return(false)
      @account.companies.should be_empty
    end

    it "should return basecamp companies if basecamp exists" do
      basecamp = mock(Basecamp)
      @account.stub!(:basecamp).and_return(basecamp)
      basecamp.should_receive(:companies).and_return([mock('Company')])
      @account.companies.should_not be_empty
    end
  end

  describe '#people' do
    before do
      @account = Account.new(:app_path => "http://test.example.com",
                             :username => "testuser",
                             :password => "password",
                             :company_id => 54321)
    end

    it "should return an empty array if basecamp doesn't exist" do
      @account.should_receive(:basecamp).and_return(false)
      @account.people.should be_empty
    end

    it "should return an empty array if company_id is blank" do
      @account.company_id = nil
      @account.people.should be_empty
    end

    it "should return basecamp companies if basecamp exists" do
      basecamp = mock(Basecamp)
      @account.stub!(:basecamp).and_return(basecamp)
      basecamp.should_receive(:people).with(54321).and_return([mock('Person')])
      @account.people.should_not be_empty
    end
  end

  describe '#projects' do
    before do
      @account = Account.new(:app_path => "http://test.example.com",
                             :username => "testuser",
                             :password => "password")
    end

    it "should return an empty array if basecamp doesn't exist" do
      @account.should_receive(:basecamp).and_return(false)
      @account.todos(1).should be_empty
    end

    it "should return an empty array if project_id is blank" do
      @account.todos(nil).should be_empty
    end

    it "should return basecamp todos for a given project if basecamp and project_id exists" do
      basecamp = mock(Basecamp)
      @account.stub!(:basecamp).and_return(basecamp)
      Basecamp::TodoList.should_receive(:all).and_return([mock('List')])
      @account.todos(2).should_not be_empty
    end
  end
end
