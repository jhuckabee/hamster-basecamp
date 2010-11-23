##
# An Activity is a the object used in Hamster that is similar
# to a Basecamp project.  This model assumes a one-to-one relationship
class Activity < ActiveRecord::Base
  has_many :facts
  belongs_to :category
  has_one :activity_project

  ##
  # Ensure that an activity project item exists for this object,
  # create it if it doesn't exist
  def ensure_activity_project_exists!
    if activity_project.blank?
      ap = build_activity_project
      ap.save
    end
  end

  ##
  # Return the Basecamp project for which this Activity corresponds
  # @return Basecamp::Project
  def project
    return if activity_project.blank? || activity_project.project_id.blank?
    @project ||= category.account.projects.detect{|p| p.id == activity_project.project_id.to_i} rescue nil
  end

  ##
  # Simple helper method to return the name of the the project 
  # that corresponds with this activity
  # @return String
  def project_name
    project.blank? ? '' : project.name
  end

  ##
  # Returns a list of Basecamp todo lists based on the configured project 
  # @return [Basecamp::TodoList]
  def todos
    return [] if category.blank? || category.account.blank? || activity_project.blank?
    @todos ||= category.account.todos(activity_project.project_id.to_i).select{|t| !t.name.blank?}
  end
end
