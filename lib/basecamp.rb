require 'net/https'
require 'yaml'
require 'date'
require 'time'
require 'xmlsimple'

# = A Ruby library for working with the Basecamp web-services API.
#
# For more information about the Basecamp web-services API, visit:
#
#   http://developer.37signals.com/basecamp
#
# NOTE: not all of Basecamp's web-services are accessible via REST. This
# library provides access to RESTful services via ActiveResource. Services not
# yet upgraded to REST are accessed via the Basecamp class. Continue reading
# for more details.
#
#
# == Establishing a Connection
#
# The first thing you need to do is establish a connection to Basecamp. This
# requires your Basecamp site address and your login credentials. Example:
#
#   Basecamp.establish_connection!('you.grouphub.com', 'username', 'password')
#
# This is the same whether you're accessing using the ActiveResource interface,
# or the legacy interface.
#
#
# == Using the REST interface via ActiveResource
#
# The REST interface is accessed via ActiveResource, a popular Ruby library
# that implements object-relational mapping for REST web-services. For more
# information on working with ActiveResource, see:
#
#  * http://api.rubyonrails.org/files/activeresource/README.html
#  * http://api.rubyonrails.org/classes/ActiveResource/Base.html
#
# === Finding a Resource
#
# Find a specific resource using the +find+ method. Attributes of the resource
# are available as instance methods on the resulting object. For example, to
# find a message with the ID of 8675309 and access its title attribute, you
# would do the following:
#
#   m = Basecamp::Message.find(8675309)
#   m.title # => 'Jenny'
#
# === Creating a Resource
#
# Create a resource by making a new instance of that resource, setting its
# attributes, and saving it. If the resource requires a prefix to identify
# it (as is the case with resources that belong to a sub-resource, such as a
# project), it should be specified when instantiating the object. Examples:
#
#   m = Basecamp::Message.new(:project_id => 1037)
#   m.category_id = 7301
#   m.title = 'Message in a bottle'
#   m.body = 'Another lonely day, with no one here but me'
#   m.save # => true
#
#   c = Basecamp::Comment.new(:post_id => 25874)
#   c.body = 'Did you get those TPS reports?'
#   c.save # => true
#
# You can also create a resource using the +create+ method, which will create
# and save it in one step. Example:
#
#   Basecamp::TodoItem.create(:todo_list_id => 3422, :contents => 'Do it')
#
# === Updating a Resource
#
# To update a resource, first find it by its id, change its attributes, and
# save it. Example:
#
#   m = Basecamp::Message.find(8675309)
#   m.body = 'Changed'
#   m.save # => true
#
# === Deleting a Resource
#
# To delete a resource, use the +delete+ method with the ID of the resource
# you want to delete. Example:
#
#   Basecamp::Message.delete(1037)
#
# === Attaching Files to a Resource
#
# If the resource accepts file attachments, the +attachments+ parameter should
# be an array of Basecamp::Attachment objects. Example:
#
#   a1 = Basecamp::Atachment.create('primary', File.read('primary.doc'))
#   a2 = Basecamp::Atachment.create('another', File.read('another.doc'))
#
#   m = Basecamp::Message.new(:project_id => 1037)
#   ...
#   m.attachments = [a1, a2]
#   m.save # => true
#
#
# = Using the non-REST inteface
#
# The non-REST interface is accessed via instance methods on the Basecamp
# class. Ensure you've established a connection, then create a new Basecamp
# instance and call methods on it. Examples:
#
#   basecamp = Basecamp.new
#
#   basecamp.projects.length      # => 5
#   basecamp.person(93832)        # => #<Record(person)..>
#   basecamp.file_categories(123) # => [#<Record(file-category)>,#<Record..>]
#
## Object attributes are accessible as methods. Example:
#
#   person = basecamp.person(93832)
#   person.first_name # => "Jason"
#
class Basecamp
  class Connection #:nodoc:
    def initialize(master)
      @master = master
      @connection = Net::HTTP.new(master.site, master.use_ssl ? 443 : 80)
      @connection.use_ssl = master.use_ssl
      @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE if master.use_ssl
    end

    def post(path, body, headers = {})
      request = Net::HTTP::Post.new(path, headers.merge('Accept' => 'application/xml'))
      request.basic_auth(@master.user, @master.password)
      @connection.request(request, body)
    end
    
    def put(path, body, headers = {})
      request = Net::HTTP::Put.new(path, headers.merge('Accept' => 'application/xml'))
      request.basic_auth(@master.user, @master.password)
      @connection.request(request, body)
    end
    
    def get(path, body, headers = {})
      request = Net::HTTP::Get.new(path, headers.merge('Accept' => 'application/xml'))
      request.basic_auth(@master.user, @master.password)
      @connection.request(request, body)
    end

    def delete(path, body=nil, headers = {})
      request = Net::HTTP::Delete.new(path, headers.merge('Accept' => 'application/xml'))
      request.basic_auth(@master.user, @master.password)
      @connection.request(request, body)
    end
  end

  class Resource < ActiveResource::Base #:nodoc:
    class << self
      def parent_resources(*parents)
        @parent_resources = parents
      end

      def element_name
        name.split(/::/).last.underscore
      end

      def prefix_source
        @parent_resources.map { |resource| "/#{resource.to_s.pluralize}/:#{resource}_id/" }.join
      end

      def prefix(options={})
        if options.any?
          options.map { |name, value| "/#{name.to_s.chomp('_id').pluralize}/#{value}/" }.join
        else
          super
        end
      end
    end

    def prefix_options
      id ? {} : super
    end
  end

  class Message < Resource
    parent_resources :project
    self.element_name = 'post'

    # Returns the most recent 25 messages in the given project (and category,
    # if specified). If you need to retrieve older messages, use the archive
    # method instead. Example:
    #
    #   Basecamp::Message.list(1037)
    #   Basecamp::Message.list(1037, :category_id => 7301)
    #
    def self.list(project_id, options = {})
      find(:all, :params => options.merge(:project_id => project_id))
    end

    # Returns a summary of all messages in the given project (and category, if
    # specified). The summary is simply the title and category of the message,
    # as well as the number of attachments (if any). Example:
    #
    #   Basecamp::Message.archive(1037)
    #   Basecamp::Message.archive(1037, :category_id => 7301)
    #
    def self.archive(project_id, options = {})
      find(:all, :params => options.merge(:project_id => project_id), :from => :archive)
    end

    def comments(options = {})
      @comments ||= Comment.find(:all, :params => options.merge(:post_id => id))
    end
  end

  # == Creating Comments for Multiple Resources
  #
  # Comments can be created for messages, milestones, and to-dos, identified
  # by the <tt>post_id</tt>, <tt>milestone_id</tt>, and <tt>todo_item_id</tt>
  # params respectively.
  #
  # For example, to create a comment on the message with id #8675309:
  #
  #   c = Basecamp::Comment.new(:post_id => 8675309)
  #   c.body = 'Great tune'
  #   c.save # => true
  #
  # Similarly, to create a comment on a milestone:
  #
  #   c = Basecamp::Comment.new(:milestone_id => 8473647)
  #   c.body = 'Is this done yet?'
  #   c.save # => true
  #
  class Comment < Resource
    parent_resources :post, :milestone, :todo_item
  end

  class TodoList < Resource
    parent_resources :project

    # Returns all lists for a project. If complete is true, only completed lists
    # are returned. If complete is false, only uncompleted lists are returned.
    def self.all(project_id, complete=nil)
      filter = case complete
        when nil   then "all"
        when true  then "finished"
        when false then "pending"
        else raise ArgumentError, "invalid value for `complete'"
      end

      find(:all, :params => { :project_id => project_id, :filter => filter })
    end

    def todo_items(options={})
      @todo_items ||= TodoItem.find(:all, :params => options.merge(:todo_list_id => id))
    end
  end

  class TodoItem < Resource
    parent_resources :todo_list

    def todo_list(options={})
      @todo_list ||= TodoList.find(todo_list_id, options)
    end

    def time_entries(options={})
      @time_entries ||= TimeEntry.find(:all, :params => options.merge(:todo_item_id => id))
    end

    def comments(options = {})
      @comments ||= Comment.find(:all, :params => options.merge(:todo_item_id => id))
    end

    def complete!
      put(:complete)
    end

    def uncomplete!
      put(:uncomplete)
    end
  end

  class TimeEntry < Resource
    parent_resources :project, :todo_item

    def self.all(project_id, page=0)
      find(:all, :params => { :project_id => project_id, :page => page })
    end

    def self.report(options={})
      find(:all, :from => :report, :params => options)
    end

    def todo_item(options={})
      @todo_item ||= todo_item_id && TodoItem.find(todo_item_id, options)
    end
  end

  class Attachment
    attr_accessor :id, :filename, :content, :content_type

    def self.create(filename, content)
      returning new(filename, content) do |attachment|
        attachment.save
      end
    end

    def initialize(filename, content, content_type = 'application/octet-stream')
      @filename, @content, @content_type = filename, content, content_type
    end

    def attributes
      { :file => id, :original_filename => filename, :content_type => content_type }
    end

    def to_xml(options = {})
      { :file => attributes }.to_xml(options)
    end

    def inspect
      to_s
    end

    def save
      response = Basecamp.connection.post('/upload', content, 'Content-Type' => content_type)

      if response.code == '200'
        self.id = Hash.from_xml(response.body)['upload']['id']
        true
      else
        raise "Could not save attachment: #{response.message} (#{response.code})"
      end
    end
  end

  class Record #:nodoc:
    attr_reader :type

    def initialize(type, hash)
      @type, @hash = type, hash
    end

    def [](name)
      name = dashify(name)

      case @hash[name]
      when Hash then 
        @hash[name] = if (@hash[name].keys.length == 1 && @hash[name].values.first.is_a?(Array))
          @hash[name].values.first.map { |v| Record.new(@hash[name].keys.first, v) }
        else
          Record.new(name, @hash[name])
        end
      else
        @hash[name]
      end
    end

    def id
      @hash['id']
    end

    def attributes
      @hash.keys
    end

    def respond_to?(sym)
      super || @hash.has_key?(dashify(sym))
    end

    def method_missing(sym, *args)
      if args.empty? && !block_given? && respond_to?(sym)
        self[sym]
      else
        super
      end
    end

    def to_s
      "\#<Record(#{@type}) #{@hash.inspect[1..-2]}>"
    end

    def inspect
      to_s
    end

    private

      def dashify(name)
        name.to_s.tr("_", "-")
      end
  end

  attr_accessor :use_xml

  class << self
    attr_reader :site, :user, :password, :use_ssl

    def establish_connection!(site, user, password, use_ssl = false)
      @site     = site
      @user     = user
      @password = password
      @use_ssl  = use_ssl

      Resource.user = user
      Resource.password = password
      Resource.site = (use_ssl ? "https" : "http") + "://" + site

      @connection = Connection.new(self)
    end

    def connection
      @connection || raise('No connection established')
    end
  end

  def initialize
    @use_xml = false
  end

  # ==========================================================================
  # GENERAL
  # ==========================================================================

  # Return account details
  def account
    record "/account.xml"
  end

  # Return the list of all accessible projects
  def projects
    records "project", "/projects.xml"
  end

  # Returns the list of message categories for the given project
  def message_categories(project_id)
    records "post-category", "/projects/#{project_id}/post_categories"
  end

  # Returns the list of file categories for the given project
  def file_categories(project_id)
    records "attachment-category", "/projects/#{project_id}/attachment_categories"
  end

  # ==========================================================================
  # CONTACT MANAGEMENT
  # ==========================================================================

  # Companies
  def companies
    records "company", "/companies.xml"
  end

  # Return information for the company with the given id
  def company(id)
    record "/contacts/company/#{id}"
  end

  # Return an array of the people in the given company. If the project-id is
  # given, only people who have access to the given project will be returned.
  def people(company_id, project_id=nil)
    url = project_id ? "/projects/#{project_id}" : ""
    url << "/contacts/people/#{company_id}"
    records "person", url
  end

  # Return information about the person with the given id
  def person(id)
    record "/contacts/person/#{id}"
  end

  # ==========================================================================
  # MILESTONES
  # ==========================================================================

  # Complete the milestone with the given id
  def complete_milestone(id)
    record "/milestones/complete/#{id}"
  end

  # Create a new milestone for the given project. +data+ must be hash of the
  # values to set, including +title+, +deadline+, +responsible_party+, and
  # +notify+.
  def create_milestone(project_id, data)
    create_milestones(project_id, [data]).first
  end

  # As #create_milestone, but can create multiple milestones in a single
  # request. The +milestones+ parameter must be an array of milestone values as
  # descrbed in #create_milestone.
  def create_milestones(project_id, milestones)
    records "milestone", "/projects/#{project_id}/milestones/create", :milestone => milestones
  end

  # Destroys the milestone with the given id.
  def delete_milestone(id)
    record "/milestones/delete/#{id}"
  end

  # Returns a list of all milestones for the given project, optionally filtered
  # by whether they are completed, late, or upcoming.
  def milestones(project_id, find="all")
    records "milestone", "/projects/#{project_id}/milestones/list", :find => find
  end

  # Uncomplete the milestone with the given id
  def uncomplete_milestone(id)
    record "/milestones/uncomplete/#{id}"
  end

  # Updates an existing milestone.
  def update_milestone(id, data, move=false, move_off_weekends=false)
    record "/milestones/update/#{id}", :milestone => data,
      :move_upcoming_milestones => move,
      :move_upcoming_milestones_off_weekends => move_off_weekends
  end

  private

    # Make a raw web-service request to Basecamp. This will return a Hash of
    # Arrays of the response, and may seem a little odd to the uninitiated.
    def request(path, parameters = {})
      response = Basecamp.connection.get(path, convert_body(parameters), "Content-Type" => content_type)

      if response.code.to_i / 100 == 2
        result = XmlSimple.xml_in(response.body, 'keeproot' => true, 'contentkey' => '__content__', 'forcecontent' => true)
        typecast_value(result)
      else
        raise "#{response.message} (#{response.code})"
      end
    end

    # A convenience method for wrapping the result of a query in a Record
    # object. This assumes that the result is a singleton, not a collection.
    def record(path, parameters={})
      result = request(path, parameters)
      (result && !result.empty?) ? Record.new(result.keys.first, result.values.first) : nil
    end

    # A convenience method for wrapping the result of a query in Record
    # objects. This assumes that the result is a collection--any singleton
    # result will be wrapped in an array.
    def records(node, path, parameters={})
      result = request(path, parameters).values.first or return []
      result = result[node] or return []
      result = [result] unless Array === result
      result.map { |row| Record.new(node, row) }
    end

    def convert_body(body)
      body = use_xml ? body.to_legacy_xml : body.to_yaml
    end

    def content_type
      use_xml ? "application/xml" : "application/x-yaml"
    end

    def typecast_value(value)
      case value
      when Hash
        if value.has_key?("__content__")
          content = translate_entities(value["__content__"]).strip
          case value["type"]
          when "integer"  then content.to_i
          when "boolean"  then content == "true"
          when "datetime" then Time.parse(content)
          when "date"     then Date.parse(content)
          else                 content
          end
        # a special case to work-around a bug in XmlSimple. When you have an empty
        # tag that has an attribute, XmlSimple will not add the __content__ key
        # to the returned hash. Thus, we check for the presense of the 'type'
        # attribute to look for empty, typed tags, and simply return nil for
        # their value.
        elsif value.keys == %w(type)
          nil
        elsif value["nil"] == "true"
          nil
        # another special case, introduced by the latest rails, where an array
        # type now exists. This is parsed by XmlSimple as a two-key hash, where
        # one key is 'type' and the other is the actual array value.
        elsif value.keys.length == 2 && value["type"] == "array"
          value.delete("type")
          typecast_value(value)
        else
          value.empty? ? nil : value.inject({}) do |h,(k,v)|
            h[k] = typecast_value(v)
            h
          end
        end
      when Array
        value.map! { |i| typecast_value(i) }
        case value.length
        when 0 then nil
        when 1 then value.first
        else value
        end
      else
        raise "can't typecast #{value.inspect}"
      end
    end

    def translate_entities(value)
      value.gsub(/&lt;/, "<").
            gsub(/&gt;/, ">").
            gsub(/&quot;/, '"').
            gsub(/&apos;/, "'").
            gsub(/&amp;/, "&")
    end
end

# A minor hack to let Xml-Simple serialize symbolic keys in hashes
class Symbol
  def [](*args)
    to_s[*args]
  end
end

class Hash
  def to_legacy_xml
    XmlSimple.xml_out({:request => self}, 'keeproot' => true, 'noattr' => true)
  end
end