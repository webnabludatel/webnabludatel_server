namespace :deploy do
  desc "Creates initial templates for server-side configs."
  task :setup_configs do
    run "mkdir -p #{shared_path}/config"
    put File.read("config/examples/database.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/examples/settings.local.yml"), "#{shared_path}/config/settings.local.yml"
    puts "Now edit the config files in #{shared_path}/config."
  end
end

after "deploy:setup", "deploy:setup_configs"
