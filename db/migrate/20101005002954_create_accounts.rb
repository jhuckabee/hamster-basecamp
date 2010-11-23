class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string  :app_path
      t.string  :username
      t.string  :password
      t.integer :category_id
      t.string  :company_id
      t.string  :user_id # This is the basecamp supplied user id for the account
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
