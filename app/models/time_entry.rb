class TimeEntry < ActiveRecord::Base
  belongs_to :fact

  before_destroy :remove_from_basecamp

  def import!
    fact.activity.category.account.create_todo(fact, todo_id)
  end

  def remove_from_basecamp
    fact.activity.category.account.destroy_time_entry(time_entry_id)
  end
end
