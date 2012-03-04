require "delayed/recipes"

set :delayed_job_args, "-n 4"

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"