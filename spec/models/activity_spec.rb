require 'spec_helper'

describe Activity do
  describe '#ensure_activity_project_exists!' do
    before do
      @activity = Activity.new
    end

    it "should create and save a new ActivityProject object if it doesn't yet exists" do
      activity_project = mock_model(ActivityProject)
      @activity.should_receive(:activity_project).and_return(nil)
      @activity.should_receive(:build_activity_project).and_return(activity_project)
      activity_project.should_receive(:save)
      @activity.ensure_activity_project_exists!
    end

    it "should not create and a new ActivityProject object if it already exists" do
      activity_project = mock_model(ActivityProject)
      @activity.should_receive(:activity_project).and_return(activity_project)
      @activity.should_not_receive(:build_activity_project)
      @activity.ensure_activity_project_exists!
    end
  end

  describe '#project' do
    before do
      @activity = Activity.new
    end

    it "shoul return nil if the activity project is blank" do
      @activity.project.should be_nil
    end

    it "should return the matching project based on the activity project" do
      activity_project = mock_model(ActivityProject, :project_id => 1)
      @activity.stub!(:activity_project).and_return(activity_project)
      category = mock_model(Category)
      @activity.stub!(:category).and_return(category)
      account = mock_model(Account)
      category.stub!(:account).and_return(account)
      project_1 = mock('Project', :id => 1)
      project_2 = mock('Project', :id => 2)
      projects = [project_1, project_2]
      account.stub!(:projects).and_return(projects)
      @activity.project.should == project_1
    end

    it "should return nil if none of the projects match the configure acitivity project" do
      activity_project = mock_model(ActivityProject, :project_id => 1)
      @activity.stub!(:activity_project).and_return(activity_project)
      category = mock_model(Category)
      @activity.stub!(:category).and_return(category)
      account = mock_model(Account)
      category.stub!(:account).and_return(account)
      project_1 = mock('Project', :id => 3)
      project_2 = mock('Project', :id => 4)
      projects = [project_1, project_2]
      account.stub!(:projects).and_return(projects)
      @activity.project.should be_nil
    end
  end

  describe '#project_name' do
    before do
      @activity = Activity.new
    end

    it "should return an empty string if the project is blank" do
      @activity.stub!(:project).and_return(nil)
      @activity.project_name.should == ''
    end

    it "should return the configured project's name if it exists" do
      project = mock('Project', :name => 'Test Project')
      @activity.stub(:project).and_return(project)
      @activity.project_name.should == 'Test Project'
    end
  end

  describe '#todos' do
    before do
      @activity = Activity.new
    end

    it "should return an empty array if the category is blank" do
      @activity.stub!(:category).and_return(nil)
      @activity.todos.should be_empty
    end

    it "should return an empty array if the category's account is blank" do
      category = mock_model(Category, :account => nil)
      @activity.stub!(:category).and_return(category)
      @activity.todos.should be_empty
    end

    it "should return an empty array if the activity project is blank" do
      category = mock_model(Category, :account => mock_model(Account))
      @activity.stub!(:category).and_return(category)
      @activity.stub!(:activity_project).and_return(nil)
      @activity.todos.should be_empty
    end

    it "should return account's todos for which the name is not blank" do
      account = mock_model(Account)
      todo_1 = mock('Todo 1', :name => "test description")
      todo_2 = mock('Todo 2', :name => '')
      account.stub!(:todos).and_return([todo_1, todo_2])
      category = mock_model(Category, :account => account)
      @activity.stub!(:category).and_return(category)
      @activity.stub!(:activity_project).and_return(mock_model(ActivityProject, :project_id => 1))
      @activity.todos.length.should == 1
    end
  end
end
