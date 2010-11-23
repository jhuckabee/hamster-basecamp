##
# Account detail class.  Handles connection to Basecamp
# and provides convenience wrapper methods for lib/basecamp.rb
class Account < ActiveRecord::Base
  belongs_to :category
  after_initialize :setup_defaults

  def setup_defaults
    @todos = {}
  end

  ##
  # Basecamp helper method returns an instance specific basecamp
  # object if valid connection credentials exist. Otherwise,
  # returns nil.
  # @return Basecamp
  def basecamp
    return nil unless establish_connection!
    @basecamp ||= Basecamp.new
  end

  ##
  # Estbalished a connection to basecamp using the configured account
  # details.  Returns nil if any of the account details is missing.
  # @return Boolean
  def establish_connection!
    return if [app_path, username, password].select{|f| f.blank? }.length > 0
    Basecamp.establish_connection!(app_path, username, password, true) unless @connection_established
    @connection_established = true
  end

  ##
  # Returns a basecamp connection object.  Ensures that a connection
  # is established first, otherwise returns nil
  # @return Basecamp::Connection
  def basecamp_connection
    return unless establish_connection!
    Basecamp.connection
  end

  ##
  # Returns a list of companies for the given account
  # @return [Basecamp::Company]
  def companies
    return [] unless basecamp
    @companies ||= basecamp.companies
  end

  ##
  # Returns a list of people for the given account
  # @return [Basecamp::People]
  def people
    return [] if company_id.blank? || !basecamp
    @people ||= basecamp.people(company_id)
  end

  ##
  # Returns a list of projects for the given account
  # @return [Basecamp::Project]
  def projects
    return [] unless basecamp
    @projects ||= basecamp.projects
  end

  ##
  # Returns a list of todos for the given account and
  # project_id. 
  #
  # TODO: Can we return a blank project id and get all todo 
  # lists for all objects???
  #
  # @return [Basecamp::TodoList]
  def todos(project_id)
    return [] if project_id.blank? || !basecamp
    @todos[project_id] ||= Basecamp::TodoList.all(project_id, false)
  end

  ##
  # Create a new time entry for a todo item
  def create_todo(fact, todo_id = nil)
    response = basecamp_connection.post("/todo_items/#{todo_id}/time_entries.xml",
                              "<time-entry>
                                  <person-id>#{fact.activity.category.account.user_id}</person-id>
                                  <date>#{fact.start_time.to_date}</date>
                                  <hours>#{fact.hours}</hours>
                                  <description>#{fact.description.gsub(/\&/, "&amp;")}</description>
                                </time-entry>", "Content-Type" => "application/xml")
    if response.code == '201'
      time_entry_id = response['location'].split('/').last
      fact.time_entry.update_attribute(:time_entry_id, time_entry_id)
      return true
    else
      puts response.inspect
      return false
    end
  end

  ##
  # Destroy a time entry
  def destroy_time_entry(time_entry_id)
    response = basecamp_connection.delete("/time_entries/#{time_entry_id}.xml")
    if response.code == '200'
      return true
    else
      return false
    end
  end

end
