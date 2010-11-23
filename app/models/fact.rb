##
# A Hamster Fact is the item where individual time entries get
# recorded.
class Fact < ActiveRecord::Base
  belongs_to :activity
  has_one :time_entry

  scope :with_no_time_entry, 
    :include => [:time_entry, :activity], 
    :conditions => "time_entries.time_entry_id is null",
    :order => 'start_time'

  ##
  # Calculate the number of minutes for this fact
  # @return Float
  def minutes
    return 0 if start_time.blank? || end_time.blank?
    (end_time - start_time)/60.0
  end

  ##
  # Calculate the number of hours for this fact
  # @return Float
  def hours
    return 0 if minutes == 0
    minutes/60.0
  end

  ##
  # Return the id for the corresponding time entry
  # @return Integer
  def time_entry_id
    time_entry.blank? ? nil : time_entry.time_entry_id
  end

  ##
  # Return the todo id for the corresponding time entry
  # @return Integer
  def todo_id
    time_entry.blank? ? nil : time_entry.todo_id
  end

  ##
  # Ignore this fact by creating a bogus time entry for it
  # in the database with a todo_id of 0
  # @return Boolean
  def ignore!
    return false if time_entry_already_exists
    build_time_entry(:time_entry_id => 0, :todo_id => 0).save
  end

  ##
  # Create a corresponding time entry for this fact and import it
  # into Basecamp
  def import!(todo_id = nil)
    return false if time_entry_already_exists
    t = build_time_entry(:time_entry_id => 0, :todo_id => todo_id)
    t.save
    t.import!
  end

private

  def time_entry_already_exists
    !time_entry.blank? && !time_entry.new_record?
  end

end
