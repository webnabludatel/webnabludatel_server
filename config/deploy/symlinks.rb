set :symlinks, %w(config/database.yml config/sensitive_data.yml)

namespace :symlinks do
  desc "Make all the damn symlinks"
  task :make, :roles => :app, :except => { :no_release => true } do
    commands = symlinks.map do |path|
      "rm -rf #{release_path}/#{path} && ln -nfs #{shared_path}/#{path} #{release_path}/#{path}"
    end

    run "cd #{release_path} && #{commands.join(" && ")}"
  end
end

after "deploy:update_code", "symlinks:make"
