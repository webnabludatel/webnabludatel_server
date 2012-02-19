set :symlinks, %w(config/database.yml config/settings.local.yml)

namespace :deploy do
  namespace :symlinks do
    desc "Creates additional symlinks for the shared configs."
    task :make, :roles => :app, :except => { :no_release => true } do
      commands = symlinks.map do |path|
        "rm -rf #{release_path}/#{path} && ln -nfs #{shared_path}/#{path} #{release_path}/#{path}"
      end

      run "cd #{release_path} && #{commands.join(" && ")}"
    end
  end
end

after "deploy:update_code", "deploy:symlinks:make"
