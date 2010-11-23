namespace "fact" do
  desc "Ignore all existing facts in the database"
  task :ignore_all => :environment do
    Fact.find(:all, :conditions => ["start_time < ?", DateTime.parse("2010-10-01")]).collect{|f| f.ignore!}
  end
end
