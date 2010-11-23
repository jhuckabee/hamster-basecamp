namespace :db do

  desc "Copy hamster database to db directory as development database"
  task :copy_hamster => :environment do
    FileUtils.cp "/home/#{ENV['USER']}/.local/share/hamster-applet/hamster.db", "#{Rails.root}/db/development.sqlite3"
  end

end
