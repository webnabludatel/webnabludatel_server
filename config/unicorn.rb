deploy_to  = "/server/www/webnabludatel.ru/main/deploy"
rails_root = "#{deploy_to}/current"
pid_file   = "#{deploy_to}/shared/pids/unicorn.pid"
socket_file= "#{deploy_to}/shared/unicorn.sock"
log_file   = "#{rails_root}/log/unicorn.log"
err_log    = "#{rails_root}/log/unicorn_error.log"
old_pid    = pid_file + '.oldbin'

timeout 30
worker_processes 2
listen socket_file, :backlog => 1024
pid pid_file
stderr_path err_log
stdout_path log_file

preload_app true # Мастер процесс загружает приложение, перед тем, как плодить рабочие процессы.

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end

before_fork do |server, worker|
  # Перед тем, как создать первый рабочий процесс, мастер отсоединяется от базы.
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Ниже идет магия, связанная с 0 downtime deploy.
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # После того как рабочий процесс создан, он устанавливает соединение с базой.
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
