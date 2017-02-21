namespace :db do
  desc 'Dump database to filesystem'
  task :pull => [:dump]

  task :dump do
    config = Rails.application.config.database_configuration[Rails.env]
    dumpfile = "#{Rails.root}/#{config['database']}.sql"
    system "mysqldump -u #{config['username']} --password=#{config['password']} --add-drop-table --skip-lock-tables --verbose #{config['database']} > #{dumpfile}"
  end
end
