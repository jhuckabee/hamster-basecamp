class TimeEntriesController < ApplicationController
  def index
    @facts = Fact.with_no_time_entry
  end

  def create
    if params[:facts]
      case params[:commit]
        when 'Ignore'
          params[:facts].each do |k,v|
            fact = Fact.find(k)
            next if fact.blank? || v[:selected].blank?
            puts "Ignoring #{fact.description}"+"*"*22
            fact.ignore!
          end
        when 'Import'
          params[:facts].each do |k,v|
            fact = Fact.find(k)
            next if fact.blank? || v[:todo_id].blank?
            puts "Importing #{fact.description}"+"*"*22
            fact.import!(v[:todo_id])
          end
      end
    end
    redirect_to time_entries_path
  end
end
