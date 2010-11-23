class CreateTimeEntries < ActiveRecord::Migration
  def self.up
    create_table :time_entries do |t|
      t.integer :fact_id
      t.string :time_entry_id
      t.string :todo_id
      t.timestamps
    end
  end

  def self.down
    drop_table :time_entries
  end
end
