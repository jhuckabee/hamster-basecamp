class CreateActivityProjects < ActiveRecord::Migration
  def self.up
    create_table :activity_projects do |t|
      t.integer :activity_id
      t.string :project_id # This is the Basecamp Project Identifier
      t.timestamps
    end
  end

  def self.down
    drop_table :activity_projects
  end
end
