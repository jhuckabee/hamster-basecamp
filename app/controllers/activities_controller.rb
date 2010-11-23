class ActivitiesController < ApplicationController
  before_filter :load_activity

  def show
  end

  # GET /activities/1/edit
  def edit
    load_projects
  end

  # PUT /activities/1
  # PUT /activities/1.xml
  def update
    respond_to do |format|
      if @activity_project.update_attributes(params[:activity_project])
        format.html { redirect_to(@activity.category.account, :notice => 'activity was successfully updated.') }
        format.xml  { head :ok }
      else
        load_projects
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete_time_entries
    params[:facts].each do |k,v|
      fact = Fact.find(k)
      next if fact.blank? || fact.time_entry.blank? || v[:selected].blank?
      fact.time_entry.destroy
    end
    redirect_to activity_path(@activity)
  end

  protected

  def load_activity
    @activity = Activity.find(params[:id])
    @activity.ensure_activity_project_exists!
    @activity_project = @activity.activity_project
  end

  def load_projects
    @projects = @activity.category.account.projects rescue []
  end
end
