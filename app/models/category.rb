class Category < ActiveRecord::Base
  has_many :activities
  has_one :account
end
